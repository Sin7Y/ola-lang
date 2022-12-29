use super::Result;
use crate::ir::Program;
use crate::sema::ast::{Expression, Function, Namespace, Statement};

/// Trait for generating IR program.
pub trait GenerateProgram<'ast> {
    type Out;

    fn generate(&'ast self, program: &mut Program) -> Result<Self::Out>;
}

impl<'ast> GenerateProgram<'ast> for Namespace {
    type Out = ();

    fn generate(&'ast self, program: &mut Program) -> Result<Self::Out> {
        // enums
        for decl in &self.enums {}

        //structs
        for decl in &self.structs {}

        // user types
        for decl in self.user_types.iter() {}

        // contracts

        for c in &self.contracts {
            // In the contract, we need to handle variables and functions
            for var in &c.variables {
                // we need to notice if the var is constant
                if var.constant {}

                // If the var has initializer, we should handle it
                if let Some(initializer) = &var.initializer {
                    generate_expr(program, initializer, self);
                }
            }

            // handle functions
            for i in &c.functions {
                let func = &self.functions[*i];

                // parameters
                if !func.params.is_empty() {}

                // returns
                if !func.returns.is_empty() {}

                // body
                generate_statement(program, &func.body, func, self);
            }
        }

        Ok(())
    }
}

fn generate_expr(program: &mut Program, expr: &Expression, ns: &Namespace) -> Result<()> {
    match expr {
        Expression::BoolLiteral(loc, val) => {}

        Expression::NumberLiteral(loc, ty, val) => {}

        Expression::StructLiteral(loc, ty, args) => {
            for (no, arg) in args.iter().enumerate() {
                generate_expr(program, arg, ns);
            }
        }
        Expression::ArrayLiteral(loc, ty, _, args) => {
            for (no, arg) in args.iter().enumerate() {
                generate_expr(program, arg, ns);
            }
        }
        Expression::ConstArrayLiteral(loc, ty, _, args) => {
            for (no, arg) in args.iter().enumerate() {
                generate_expr(program, arg, ns);
            }
        }
        Expression::ZeroExt { loc, to, expr } => {
            generate_expr(program, expr, ns);
        }
        Expression::Trunc { loc, to, expr } => {
            generate_expr(program, expr, ns);
        }
        Expression::Cast { loc, to, expr } => {
            generate_expr(program, expr, ns);
        }
        Expression::Add(loc, ty, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::Subtract(loc, ty, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::Multiply(loc, ty, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::Divide(loc, ty, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::Modulo(loc, ty, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::Power(loc, ty, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::BitwiseOr(loc, ty, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::BitwiseAnd(loc, ty, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::BitwiseXor(loc, ty, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::ShiftLeft(loc, ty, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::ShiftRight(loc, ty, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::ConstantVariable(loc, ty, contract, var_no) => {}
        Expression::Variable(loc, ty, var_no) => {}
        Expression::StorageVariable(loc, ty, contract, var_no) => {}

        Expression::StorageLoad(loc, ty, expr) => {
            generate_expr(program, expr, ns);
        }

        Expression::Increment(loc, ty, expr) => {
            generate_expr(program, expr, ns);
        }
        Expression::Decrement(loc, ty, expr) => {
            generate_expr(program, expr, ns);
        }

        Expression::Assign(loc, ty, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }

        Expression::More(loc, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::Less(loc, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::MoreEqual(loc, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::LessEqual(loc, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::Equal(loc, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::NotEqual(loc, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }

        Expression::Not(loc, expr) => {
            generate_expr(program, expr, ns);
        }
        Expression::Complement(loc, ty, expr) => {
            generate_expr(program, expr, ns);
        }
        Expression::UnaryMinus(loc, ty, expr) => {
            generate_expr(program, expr, ns);
        }

        Expression::ConditionalOperator(loc, ty, cond, left, right) => {
            generate_expr(program, cond, ns);
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::Subscript(loc, _, ty, array, index) => {
            generate_expr(program, array, ns);
            generate_expr(program, index, ns);
        }
        Expression::StructMember(loc, ty, var, member) => {
            generate_expr(program, var, ns);
        }

        Expression::StorageArrayLength {
            loc,
            ty,
            array,
            elem_ty,
        } => {
            generate_expr(program, array, ns);
        }

        Expression::Or(loc, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }
        Expression::And(loc, left, right) => {
            generate_expr(program, left, ns);
            generate_expr(program, right, ns);
        }

        Expression::Function {
            loc,
            ty,
            function_no,
            signature,
        } => {}
        Expression::FunctionCall {
            loc,
            function,
            args,
            ..
        } => {
            generate_expr(program, function, ns);

            for (no, arg) in args.iter().enumerate() {
                generate_expr(program, arg, ns);
            }
        }

        Expression::Builtin(loc, _, builtin, args) => {
            for (no, arg) in args.iter().enumerate() {
                generate_expr(program, arg, ns);
            }
        }

        Expression::List(loc, list) => {
            for (no, expr) in list.iter().enumerate() {
                generate_expr(program, expr, ns);
            }
        }
    }
    Ok(())
}

fn generate_statement(program: &mut Program, stmts: &[Statement], func: &Function, ns: &Namespace) {
    for stmt in stmts {
        match stmt {
            Statement::Block { loc, statements } => {
                generate_statement(program, statements, func, ns);
            }
            Statement::VariableDecl(loc, _, param, init) => {
                if let Some(init) = init {
                    generate_expr(program, init, ns);
                }
            }
            Statement::If(loc, _, cond, then, else_) => {
                generate_expr(program, cond, ns);
                generate_statement(program, then, func, ns);
                generate_statement(program, else_, func, ns);
            }

            Statement::For {
                loc,
                init,
                cond,
                next,
                body,
                ..
            } => {
                generate_statement(program, init, func, ns);
                if let Some(cond) = cond {
                    generate_expr(program, cond, ns);
                }
                generate_statement(program, next, func, ns);
                generate_statement(program, body, func, ns);
            }

            Statement::Expression(loc, _, expr) => {
                let labels = vec![String::from("expression"), ns.loc_to_string(loc)];
                generate_expr(program, expr, ns);
            }

            Statement::Continue(loc) => {}
            Statement::Break(loc) => {}
            Statement::Return(loc, expr) => {
                if let Some(expr) = expr {
                    generate_expr(program, expr, ns);
                }
            }

            Statement::Underscore(loc) => {}
        }
    }
}
