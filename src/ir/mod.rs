// Structs of IR:
//   programs ([`Program`]), functions ([`Function`],
//   -> [`FunctionData`]), basic blocks ([`BasicBlock`],
//       -> [`BasicBlockData`](entities::BasicBlockData)), values ([`Value`],
//          -> [`ValueData`](entities::ValueData)).
// Types of IR values ([`Type`]).
// IR builders ([`builder`]).

pub mod builder;
pub mod dfg;
pub mod layout;
pub mod program;
pub mod selector;
pub mod types;
pub mod values;

pub mod builder_traits {
    pub use super::builder::{
        BasicBlockBuilder, GlobalInstBuilder, LocalInstBuilder, ValueBuilder,
    };
}

pub use program::{BasicBlock, Function, FunctionData, Program, Value, ValueKind};
pub use types::{Type, TypeKind};
pub use values::BinaryOp;
