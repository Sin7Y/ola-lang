// SPDX-License-Identifier: Apache-2.0

use serde::Serialize;
use std::collections::HashMap;


#[derive(Serialize)]
pub struct JsonResult {
    pub errors: Vec<OutputJson>,
    pub target: String,
    #[serde(skip_serializing_if = "String::is_empty")]
    pub program: String,
    pub contracts: HashMap<String, HashMap<String, JsonContract>>,
}

#[derive(Serialize)]
pub struct LocJson {
    pub file: String,
    pub start: usize,
    pub end: usize,
}

#[derive(Serialize)]
#[allow(non_snake_case)]
pub struct OutputJson {
    pub sourceLocation: Option<LocJson>,
    #[serde(rename = "type")]
    pub ty: String,
    pub component: String,
    pub severity: String,
    pub message: String,
    pub formattedMessage: String,
}
