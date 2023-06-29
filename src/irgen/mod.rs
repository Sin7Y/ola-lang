use std::str;
pub mod binary;
mod corelib;
mod dispatch;
mod encoding;
mod expression;
mod functions;
mod statements;
pub mod storage;
pub mod u32_op;
mod unused_variable;

use crate::sema::ast;

#[macro_export]
macro_rules! emit_context {
    ($binary:expr) => {
        #[allow(unused_macros)]
        macro_rules! i64_const {
            ($val:expr) => {
                $binary.context.i64_type().const_int($val, false)
            };
        }

        #[allow(unused_macros)]
        macro_rules! i64_zero {
            () => {
                $binary.context.i64_type().const_zero()
            };
        }
        #[allow(unused_macros)]
        macro_rules! array_type {
            ($val:expr) => {
                $binary.context.i64_type().array_type($val)
            };
        }

        #[allow(unused_macros)]
        macro_rules! call {
            ($name:expr, $args:expr) => {
                $binary
                    .builder
                    .build_call($binary.module.get_function($name).unwrap(), $args, "")
                    .try_as_basic_value()
                    .left()
                    .unwrap()
            };
            ($name:expr, $args:expr, $call_name:literal) => {
                $binary
                    .builder
                    .build_call(
                        $binary.module.get_function($name).unwrap(),
                        $args,
                        $call_name,
                    )
                    .try_as_basic_value()
                    .left()
                    .unwrap()
            };

            ($void:expr, $name:expr, $args:expr) => {
                $binary
                    .builder
                    .build_call($binary.module.get_function($name).unwrap(), $args, "")
            };

            ($void:expr, $name:expr, $args:expr, $call_name:literal) => {
                $binary.builder.build_call(
                    $binary.module.get_function($name).unwrap(),
                    $args,
                    $call_name,
                )
            };
        }
    };
}

impl ast::Contract {
    /// Generate the binary. This can be used to generate llvm text, object file
    /// or final linked binary.
    pub fn binary<'a>(
        &'a self,
        ns: &'a ast::Namespace,
        context: &'a inkwell::context::Context,
        filename: &'a str,
    ) -> binary::Binary {
        binary::Binary::build(context, self, ns, filename)
    }
}
