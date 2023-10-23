// SPDX-License-Identifier: Apache-2.0

use crate::sema::ast::Namespace;

use self::ola_abi::gen_abi;

pub mod ola_abi;

pub fn generate_abi(contract_no: usize, ns: &Namespace) -> (String, &'static str) {
    let abi = gen_abi(contract_no, ns);

    (serde_json::to_string_pretty(&abi).unwrap(), "json")
}
