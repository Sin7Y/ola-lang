// SPDX-License-Identifier: Apache-2.0

use crate::sema::ast::{Expression, Namespace, Type, Type::Uint};
use std::collections::HashMap;

use super::buffer_validator::BufferValidator;

pub(super) struct ScaleEncoding {
    storage_cache: HashMap<usize, Expression>,
    packed_encoder: bool,
}

impl ScaleEncoding {
    pub fn new(packed: bool) -> Self {
        Self {
            storage_cache: HashMap::new(),
            packed_encoder: packed,
        }
    }
}
