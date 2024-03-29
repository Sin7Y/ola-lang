use crate::sema::ast::{Expression, Namespace, Symbol, Type};
use crate::sema::diagnostics::Diagnostics;
use crate::sema::expression::function_call::available_functions;
use crate::sema::expression::{ExprContext, ResolveTo};
use crate::sema::symtable::Symtable;
use ola_parser::diagnostics::Diagnostic;
use ola_parser::program;

pub(super) fn variable(
    id: &program::Identifier,
    context: &mut ExprContext,
    ns: &mut Namespace,
    symtable: &mut Symtable,
    diagnostics: &mut Diagnostics,
    resolve_to: ResolveTo,
) -> Result<Expression, ()> {
    if let Some(v) = symtable.find(&id.name) {
        return if context.constant {
            diagnostics.push(Diagnostic::error(
                id.loc,
                format!("cannot read variable '{}' in constant expression", id.name),
            ));
            Err(())
        } else {
            Ok(Expression::Variable {
                loc: id.loc,
                ty: v.ty.clone(),
                var_no: v.pos,
            })
        };
    }

    // are we trying to resolve a function type?
    let function_first = if let ResolveTo::Type(resolve_to) = resolve_to {
        matches!(resolve_to, Type::Function { .. })
    } else {
        false
    };

    match ns.resolve_var(context.file_no, context.contract_no, id, function_first) {
        Some(Symbol::Variable(_, Some(var_contract_no), var_no)) => {
            let var_contract_no = *var_contract_no;
            let var_no = *var_no;

            let var = &ns.contracts[var_contract_no].variables[var_no];

            if var.constant {
                Ok(Expression::ConstantVariable {
                    loc: id.loc,
                    ty: var.ty.clone(),
                    contract_no: Some(var_contract_no),
                    var_no,
                })
            } else if context.constant {
                diagnostics.push(Diagnostic::error(
                    id.loc,
                    format!(
                        "cannot read contract variable '{}' in constant expression",
                        id.name
                    ),
                ));
                Err(())
            } else {
                Ok(Expression::StorageVariable {
                    loc: id.loc,
                    ty: Type::StorageRef(Box::new(var.ty.clone())),
                    contract_no: var_contract_no,
                    var_no,
                })
            }
        }
        Some(Symbol::Variable(_, None, var_no)) => {
            let var_no = *var_no;

            let var = &ns.constants[var_no];

            Ok(Expression::ConstantVariable {
                loc: id.loc,
                ty: var.ty.clone(),
                contract_no: None,
                var_no,
            })
        }
        Some(Symbol::Function(_)) => {
            let mut name_matches = 0;
            let mut expr = None;

            for function_no in available_functions(&id.name, context.contract_no, ns) {
                let func = &ns.functions[function_no];

                let ty = Type::Function {
                    params: func.params.iter().map(|p| p.ty.clone()).collect(),
                    returns: func.returns.iter().map(|p| p.ty.clone()).collect(),
                };

                name_matches += 1;
                expr = Some(Expression::Function {
                    loc: id.loc,
                    ty,
                    function_no,
                    signature: None,
                });
            }

            if name_matches == 1 {
                Ok(expr.unwrap())
            } else {
                diagnostics.push(Diagnostic::error(
                    id.loc,
                    format!("function '{}' is overloaded", id.name),
                ));
                Err(())
            }
        }
        sym => {
            diagnostics.push(Namespace::wrong_symbol(sym, id));
            Err(())
        }
    }
}
