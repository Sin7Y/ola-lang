// SPDX-License-Identifier: Apache-2.0

use crate::sema::ast::Expression::LibFunction;
use crate::sema::ast::{Diagnostic, Expression, LibFunc, Namespace};
use crate::sema::symtable::{Symtable, VariableUsage};
use crate::sema::{ast, symtable};

/// Mark variables as assigned, either in the symbol table (for local variables)
/// or in the Namespace (for storage variables)
pub fn assigned_variable(ns: &mut Namespace, exp: &Expression, symtable: &mut Symtable) {
    match &exp {
        Expression::StorageVariable(_, _, contract_no, offset) => {
            ns.contracts[*contract_no].variables[*offset].assigned = true;
        }

        Expression::Variable(_, _, offset) => {
            let var = symtable.vars.get_mut(offset).unwrap();
            var.assigned = true;
        }

        Expression::StructMember(_, _, str, _) => {
            assigned_variable(ns, str, symtable);
        }

        Expression::Subscript(_, _, _, array, index) => {
            assigned_variable(ns, array, symtable);
            used_variable(ns, index, symtable);
        }

        Expression::StorageLoad(_, _, expr)
        | Expression::Load(.., expr)
        | Expression::Trunc { expr, .. }
        | Expression::Cast { expr, .. } => {
            assigned_variable(ns, expr, symtable);
        }

        _ => {}
    }
}

/// Mark variables as used, either in the symbol table (for local variables) or
/// in the Namespace (for global constants and storage variables)
/// The functions handles complex expressions in a recursive fashion, such as
/// array length call, assign expressions and array subscripts.
pub fn used_variable(ns: &mut Namespace, exp: &Expression, symtable: &mut Symtable) {
    match &exp {
        Expression::StorageVariable(_, _, contract_no, offset) => {
            ns.contracts[*contract_no].variables[*offset].read = true;
        }

        Expression::Variable(_, _, offset) => {
            let var = symtable.vars.get_mut(offset).unwrap();
            var.read = true;
        }

        Expression::ConstantVariable(_, _, Some(contract_no), offset) => {
            ns.contracts[*contract_no].variables[*offset].read = true;
        }

        Expression::ConstantVariable(_, _, None, offset) => {
            ns.constants[*offset].read = true;
        }

        Expression::StructMember(_, _, str, _) => {
            used_variable(ns, str, symtable);
        }

        Expression::Subscript(_, _, _, array, index) => {
            used_variable(ns, array, symtable);
            used_variable(ns, index, symtable);
        }
        Expression::LibFunction(_, _, LibFunc::ArrayLength, args) => {
            // We should not eliminate an array from the code when 'length' is called
            // So the variable is also assigned
            assigned_variable(ns, &args[0], symtable);
            used_variable(ns, &args[0], symtable);
        }

        Expression::StorageArrayLength {
            loc: _,
            ty: _,
            array,
            ..
        } => {
            //We should not eliminate an array from the code when 'length' is called
            //So the variable is also assigned
            assigned_variable(ns, array, symtable);
            used_variable(ns, array, symtable);
        }

        Expression::StorageLoad(_, _, expr)
        | Expression::Load(.., expr)
        | Expression::ZeroExt { expr, .. }
        | Expression::Trunc { expr, .. }
        | Expression::Cast { expr, .. } => {
            used_variable(ns, expr, symtable);
        }

        Expression::FunctionCall { .. } => {
            check_function_call(ns, exp, symtable);
        }

        _ => {}
    }
}

/// Mark function arguments as used. If the function is an attribute of another
/// variable, mark the usage of the latter as well
pub fn check_function_call(ns: &mut Namespace, exp: &Expression, symtable: &mut Symtable) {
    match &exp {
        Expression::Load { .. } | Expression::StorageLoad(..) | Expression::Variable(..) => {
            used_variable(ns, exp, symtable);
        }
        Expression::FunctionCall {
            loc: _,
            returns: _,
            function,
            args,
        } => {
            for arg in args {
                used_variable(ns, arg, symtable);
            }
            check_function_call(ns, function, symtable);
        }
        Expression::LibFunction(_, _, expr_type, args) => match expr_type {
            LibFunc::ArrayPush => {
                assigned_variable(ns, &args[0], symtable);
                if args.len() > 1 {
                    used_variable(ns, &args[1], symtable);
                }
            }

            _ => {
                for arg in args {
                    used_variable(ns, arg, symtable);
                }
            }
        },

        _ => {}
    }
}

/// Marks as used variables that appear in an expression with right and left
/// hand side.
pub fn check_var_usage_expression(
    ns: &mut Namespace,
    left: &Expression,
    right: &Expression,
    symtable: &mut Symtable,
) {
    used_variable(ns, left, symtable);
    used_variable(ns, right, symtable);
}

/// Emit different warning types according to the function variable usage
pub fn emit_warning_local_variable(variable: &symtable::Variable) -> Option<Diagnostic> {
    match &variable.usage_type {
        VariableUsage::Parameter => {
            if !variable.read {
                return Some(Diagnostic::warning(
                    variable.id.loc,
                    format!(
                        "function parameter '{}' has never been read",
                        variable.id.name
                    ),
                ));
            }
            None
        }

        VariableUsage::ReturnVariable => {
            if !variable.assigned {
                return Some(Diagnostic::warning(
                    variable.id.loc,
                    format!(
                        "return variable '{}' has never been assigned",
                        variable.id.name
                    ),
                ));
            }
            None
        }

        VariableUsage::LocalVariable => {
            let assigned = variable.initializer.has_initializer() || variable.assigned;
            if !assigned && !variable.read {
                return Some(Diagnostic::warning(
                    variable.id.loc,
                    format!(
                        "local variable '{}' has never been read nor assigned",
                        variable.id.name
                    ),
                ));
            } else if assigned && !variable.read {
                // Values assigned to variables that reference others change the value of its
                // reference No warning needed in this case
                return Some(Diagnostic::warning(
                    variable.id.loc,
                    format!(
                        "local variable '{}' has been assigned, but never read",
                        variable.id.name
                    ),
                ));
            }
            None
        }
        VariableUsage::DestructureVariable => {
            if !variable.read {
                return Some(Diagnostic::warning(
                    variable.id.loc,
                    format!(
                        "destructure variable '{}' has never been used",
                        variable.id.name
                    ),
                ));
            }

            None
        }
        VariableUsage::AnonymousReturnVariable => None,
    }
}

/// Emit warnings depending on the storage variable usage
fn emit_warning_contract_variables(variable: &ast::Variable) -> Option<Diagnostic> {
    if variable.assigned && !variable.read {
        return Some(Diagnostic::warning(
            variable.loc,
            format!(
                "storage variable '{}' has been assigned, but never read",
                variable.name
            ),
        ));
    } else if !variable.assigned && !variable.read {
        return Some(Diagnostic::warning(
            variable.loc,
            format!("storage variable '{}' has never been used", variable.name),
        ));
    }

    None
}

/// Check for unused constants and storage variables
pub fn check_unused_namespace_variables(ns: &mut Namespace) {
    for contract in &ns.contracts {
        for variable in &contract.variables {
            if let Some(warning) = emit_warning_contract_variables(variable) {
                ns.diagnostics.push(warning);
            }
        }
    }

    // Global constants should have been initialized during declaration
    for constant in &ns.constants {
        if !constant.read {
            ns.diagnostics.push(Diagnostic::warning(
                constant.loc,
                format!("global constant '{}' has never been used", constant.name),
            ));
        }
    }
}
