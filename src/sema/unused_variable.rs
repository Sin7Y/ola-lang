// SPDX-License-Identifier: Apache-2.0
use crate::sema::ast::{Diagnostic, Expression, LibFunc, Namespace, RetrieveType};
use crate::sema::symtable::{Symtable, VariableUsage};
use crate::sema::{ast, symtable};

use super::ast::CallArgs;

/// Mark variables as assigned, either in the symbol table (for local variables)
/// or in the Namespace (for storage variables)
pub fn assigned_variable(ns: &mut Namespace, exp: &Expression, symtable: &mut Symtable) {
    match &exp {
        Expression::StorageVariable {
            contract_no,
            var_no,
            ..
        } => {
            ns.contracts[*contract_no].variables[*var_no].assigned = true;
        }

        Expression::Variable { var_no, .. } => {
            let var = symtable.vars.get_mut(var_no).unwrap();
            var.assigned = true;
        }

        Expression::StructMember { expr, .. } => {
            assigned_variable(ns, expr, symtable);
        }

        Expression::Subscript { array, index, .. } => {
            if array.ty().is_contract_storage() {
                subscript_variable(ns, array, symtable);
            } else {
                assigned_variable(ns, array, symtable);
            }
            used_variable(ns, index, symtable);
        }

        Expression::StorageLoad { expr, .. }
        | Expression::Load { expr, .. }
        | Expression::Trunc { expr, .. }
        | Expression::Cast { expr, .. } => {
            assigned_variable(ns, expr, symtable);
        }

        _ => {}
    }
}

// We have two cases here
//  contract c {
//      u32[2] case1;
//
//      function f(u32[2] case2) {
//          case1[0] = 1;
//          case2[0] = 1;
//      }
//  }
//  The subscript for case1 is an assignment
//  The subscript for case2 is a read
fn subscript_variable(ns: &mut Namespace, exp: &Expression, symtable: &mut Symtable) {
    match &exp {
        Expression::StorageVariable {
            contract_no,
            var_no,
            ..
        } => {
            ns.contracts[*contract_no].variables[*var_no].assigned = true;
        }

        Expression::Variable { var_no, .. } => {
            let var = symtable.vars.get_mut(var_no).unwrap();
            var.read = true;
        }

        Expression::StructMember { expr, .. } => {
            subscript_variable(ns, expr, symtable);
        }

        Expression::Subscript { array, index, .. } => {
            subscript_variable(ns, array, symtable);
            subscript_variable(ns, index, symtable);
        }

        Expression::FunctionCall { .. } | Expression::ExternalFunctionCall { .. } => {
            check_function_call(ns, exp, symtable);
        }

        _ => (),
    }
}

/// Mark variables as used, either in the symbol table (for local variables) or
/// in the Namespace (for global constants and storage variables)
/// The functions handles complex expressions in a recursive fashion, such as
/// array length call, assign expressions and array subscripts.
pub fn used_variable(ns: &mut Namespace, exp: &Expression, symtable: &mut Symtable) {
    match &exp {
        Expression::StorageVariable {
            contract_no,
            var_no,
            ..
        } => {
            ns.contracts[*contract_no].variables[*var_no].read = true;
        }

        Expression::Variable { var_no, .. } => {
            let var = symtable.vars.get_mut(var_no).unwrap();
            var.read = true;
        }

        Expression::ConstantVariable {
            contract_no: Some(contract_no),
            var_no,
            ..
        } => {
            ns.contracts[*contract_no].variables[*var_no].read = true;
        }

        Expression::ConstantVariable {
            contract_no: None,
            var_no,
            ..
        } => {
            ns.constants[*var_no].read = true;
        }

        Expression::StructMember { expr, .. } => {
            used_variable(ns, expr, symtable);
        }

        Expression::Subscript { array, index, .. } => {
            used_variable(ns, array, symtable);
            used_variable(ns, index, symtable);
        }
        Expression::ArraySlice {
            array, start, end, ..
        } => {
            used_variable(ns, array, symtable);
            if let Some(start) = start {
                used_variable(ns, start, symtable);
            }
            if let Some(end) = end {
                used_variable(ns, end, symtable);
            }
        }
        Expression::LibFunction {
            kind: LibFunc::ArrayLength,
            args,
            ..
        } => {
            // We should not eliminate an array from the code when 'length' is called
            // So the variable is also assigned
            assigned_variable(ns, &args[0], symtable);
            used_variable(ns, &args[0], symtable);
        }
        Expression::LibFunction {
            kind: LibFunc::ArrayPush | LibFunc::ArrayPop,
            args,
            ..
        } => {
            // Array push and pop return values, so they are both read and assigned.
            used_variable(ns, &args[0], symtable);
            assigned_variable(ns, &args[0], symtable);
        }

        Expression::StorageArrayLength { array, .. } => {
            // We should not eliminate an array from the code when 'length' is called
            // So the variable is also assigned
            assigned_variable(ns, array, symtable);
            used_variable(ns, array, symtable);
        }
        Expression::StorageLoad { expr, .. }
        | Expression::Load { expr, .. }
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
        Expression::Load { .. } | Expression::StorageLoad { .. } | Expression::Variable { .. } => {
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

        Expression::ExternalFunctionCall {
            function,
            args,
            call_args,
            ..
        } => {
            for arg in args {
                used_variable(ns, arg, symtable);
            }
            check_call_args(ns, call_args, symtable);
            check_function_call(ns, function, symtable);
        }

        Expression::ExternalFunctionCallRaw {
            address,
            args,
            call_args,
            ..
        } => {
            used_variable(ns, args, symtable);
            used_variable(ns, address, symtable);
            check_call_args(ns, call_args, symtable);
        }
        Expression::LibFunction {
            kind: expr_type,
            args,
            ..
        } => match expr_type {
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

        Expression::ExternalFunction { address, .. } => {
            used_variable(ns, address, symtable);
        }

        _ => {}
    }
}

/// Mark function call arguments as used
fn check_call_args(ns: &mut Namespace, call_args: &CallArgs, symtable: &mut Symtable) {
    if let Some(gas) = &call_args.gas {
        used_variable(ns, gas.as_ref(), symtable);
    }
    if let Some(value) = &call_args.value {
        used_variable(ns, value.as_ref(), symtable);
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
pub fn emit_warning_local_variable(
    variable: &symtable::Variable,
    ns: &Namespace,
) -> Option<Diagnostic> {
    match &variable.usage_type {
        VariableUsage::Parameter => {
            if (!variable.read && !variable.ty.is_reference_type(ns))
                || (!variable.read && !variable.assigned && variable.ty.is_reference_type(ns))
            {
                return Some(Diagnostic::warning(
                    variable.id.loc,
                    format!("function parameter '{}' is unused", variable.id.name),
                ));
            }
            None
        }

        VariableUsage::ReturnVariable => {
            if !variable.assigned {
                if variable.ty.is_contract_storage() {
                    return Some(Diagnostic::error(
                        variable.id.loc,
                        format!(
                            "storage reference '{}' must be assigned a value",
                            variable.id.name
                        ),
                    ));
                } else {
                    return Some(Diagnostic::warning(
                        variable.id.loc,
                        format!(
                            "return variable '{}' has never been assigned",
                            variable.id.name
                        ),
                    ));
                }
            }
            None
        }

        VariableUsage::LocalVariable => {
            let assigned = variable.initializer.has_initializer() || variable.assigned;
            if !variable.assigned && !variable.read {
                return Some(Diagnostic::warning(
                    variable.id.loc,
                    format!("local variable '{}' is unused", variable.id.name),
                ));
            } else if assigned && !variable.read && !variable.is_reference() {
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
