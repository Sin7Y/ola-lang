// SPDX-License-Identifier: Apache-2.0

// ethereum style ABIs
use crate::sema::ast::{Namespace, Parameter, Type};
use serde::Serialize;

#[derive(Serialize)]
#[allow(clippy::upper_case_acronyms)]
pub struct ABIParam {
    pub name: String,
    #[serde(rename = "type")]
    pub ty: String,
    #[serde(rename = "internalType")]
    pub internal_ty: String,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub components: Vec<ABIParam>,
}

#[derive(Serialize)]
#[allow(clippy::upper_case_acronyms)]
pub struct ABI {
    #[serde(skip_serializing_if = "String::is_empty")]
    pub name: String,
    #[serde(rename = "type")]
    pub ty: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub inputs: Option<Vec<ABIParam>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub outputs: Option<Vec<ABIParam>>,
}



impl Type {
    /// Is this type a struct, or an array of structs?
    fn is_struct_or_array_of_struct(&self) -> Option<usize> {
        match self {
            Type::Struct(n) => Some(*n),
            Type::Array(ty, _) => ty.is_struct_or_array_of_struct(),
            _ => None,
        }
    }
}

pub fn gen_abi(contract_no: usize, ns: &Namespace) -> Vec<ABI> {
    fn parameter_to_abi(param: &Parameter, ns: &Namespace) -> ABIParam {
        let components = if let Some(n) = param.ty.is_struct_or_array_of_struct() {
            ns.structs[n]
                .fields
                .iter()
                .map(|p| parameter_to_abi(p, ns))
                .collect::<Vec<ABIParam>>()
        } else {
            Vec::new()
        };

        ABIParam {
            name: param.name_as_str().to_owned(),
            ty: param.ty.to_signature_string(true, ns),
            internal_ty: param.ty.to_string(ns),
            components,
        }
    }

    ns.contracts[contract_no]
        .all_functions
        .keys()
        .filter_map(|function_no| {
            let func = &ns.functions[*function_no];
            return Some(func);
        })
        .map(|func| ABI {
            name: func.name.to_owned(),
            ty: "function".to_string(),
            inputs: Some(
                func.params
                    .iter()
                    .map(|p| parameter_to_abi(p, ns))
                    .collect(),
            ),
            outputs: Some(
                func.returns
                    .iter()
                    .map(|p| parameter_to_abi(p, ns))
                    .collect(),
            ),
        })
        .collect()
}
