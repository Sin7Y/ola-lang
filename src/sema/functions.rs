// SPDX-License-Identifier: Apache-2.0

use super::{
    ast::{Diagnostic, Expression, Function, Namespace, Parameter, Symbol, Type},
    diagnostics::Diagnostics,
    expression::{expression, ExprContext, ResolveTo},
    Symtable,
};

use ola_parser::{
    program,
    program::{CodeLocation, OptionalCodeLocation},
};

/// Resolve function declaration in a contract
pub fn contract_function(
    contract: &program::ContractDefinition,
    func: &program::FunctionDefinition,
    file_no: usize,
    contract_no: usize,
    ns: &mut Namespace,
) -> Option<usize> {
    let mut success = true;

    // Function name cannot be the same as the contract name
    if let Some(n) = &func.name {
        if n.name == ns.contracts[contract_no].name {
            ns.diagnostics.push(Diagnostic::error(
                func.loc,
                "function cannot have same name as the contract".to_string(),
            ));
            return None;
        }
    } else {
        ns.diagnostics.push(Diagnostic::error(
                func.name_loc,
                "function is missing a name. A function without a name is syntax for 'fallback() external' or 'receive() external' in older versions of the Solidity language, see https://solang.readthedocs.io/en/latest/language/functions.html#fallback-and-receive-function".to_string(),
            ));
        return None;
    }

    let mut diagnostics = Diagnostics::default();

    let (params, params_success) = resolve_params(
        &func.params,
        file_no,
        Some(contract_no),
        ns,
        &mut diagnostics,
    );

    let (returns, returns_success) = resolve_returns(
        &func.returns,
        file_no,
        Some(contract_no),
        ns,
        &mut diagnostics,
    );

    ns.diagnostics.extend(diagnostics);

    if !success || !returns_success || !params_success {
        return None;
    }

    let name = func
        .name
        .as_ref()
        .map(|s| s.name.as_str())
        .unwrap()
        .to_owned();

    let mut fdecl = Function::new(func.loc, name, Some(contract_no), params, returns, ns);

    fdecl.has_body = func.body.is_some();

    let id = func.name.as_ref().unwrap();

    if let Some(func_no) = ns.contracts[contract_no]
        .all_functions
        .keys()
        .find(|func_no| {
            let func = &ns.functions[**func_no];

            func.signature == fdecl.signature
        })
    {
        ns.diagnostics.push(Diagnostic::error_with_note(
            func.loc,
            format!("overloaded fn with this signature already exist"),
            ns.functions[*func_no].loc,
            "location of previous definition".to_string(),
        ));

        return None;
    }

    let func_no = ns.functions.len();

    ns.functions.push(fdecl);
    ns.contracts[contract_no].functions.push(func_no);

    if let Some(Symbol::Function(ref mut v)) =
        ns.function_symbols
            .get_mut(&(file_no, Some(contract_no), id.name.to_owned()))
    {
        v.push((func.loc, func_no));
    } else {
        ns.add_symbol(
            file_no,
            Some(contract_no),
            id,
            Symbol::Function(vec![(id.loc, func_no)]),
        );
    }

    Some(func_no)
}

/// Resolve free function
pub fn function(
    func: &program::FunctionDefinition,
    file_no: usize,
    ns: &mut Namespace,
) -> Option<usize> {
    let mut success = true;

    let mut diagnostics = Diagnostics::default();

    let (params, params_success) =
        resolve_params(&func.params, file_no, None, ns, &mut diagnostics);

    let (returns, returns_success) =
        resolve_returns(&func.returns, file_no, None, ns, &mut diagnostics);

    ns.diagnostics.extend(diagnostics);

    if func.body.is_none() {
        ns.diagnostics.push(Diagnostic::error(
            func.loc,
            String::from("missing function body"),
        ));
        success = false;
    }

    if !success || !returns_success || !params_success {
        return None;
    }

    let name = match &func.name {
        Some(s) => s.name.to_owned(),
        None => {
            ns.diagnostics.push(Diagnostic::error(
                func.loc,
                String::from("missing function name"),
            ));
            return None;
        }
    };

    let mut fdecl = Function::new(func.loc, name, None, params, returns, ns);

    fdecl.has_body = true;

    let id = func.name.as_ref().unwrap();

    if let Some(prev) = ns.functions.iter().find(|f| fdecl.signature == f.signature) {
        ns.diagnostics.push(Diagnostic::error_with_note(
            func.loc,
            format!("overloaded fn with this signature already exist"),
            prev.loc,
            "location of previous definition".to_string(),
        ));

        return None;
    }

    let func_no = ns.functions.len();

    ns.functions.push(fdecl);

    if let Some(Symbol::Function(ref mut v)) =
        ns.function_symbols
            .get_mut(&(file_no, None, id.name.to_owned()))
    {
        v.push((func.loc, func_no));
    } else {
        ns.add_symbol(file_no, None, id, Symbol::Function(vec![(id.loc, func_no)]));
    }

    Some(func_no)
}

/// Resolve the parameters
pub fn resolve_params(
    parameters: &[(program::Loc, Option<program::Parameter>)],
    file_no: usize,
    contract_no: Option<usize>,
    ns: &mut Namespace,
    diagnostics: &mut Diagnostics,
) -> (Vec<Parameter>, bool) {
    let mut params = Vec::new();
    let mut success = true;

    for (loc, p) in parameters {
        let p = match p {
            Some(p) => p,
            None => {
                diagnostics.push(Diagnostic::error(*loc, "missing parameter type".to_owned()));
                success = false;
                continue;
            }
        };

        let mut ty_loc = p.ty.loc();

        match ns.resolve_type(file_no, contract_no, &p.ty, diagnostics) {
            Ok(ty) => {
                params.push(Parameter {
                    loc: *loc,
                    id: p.name.clone(),
                    ty,
                    ty_loc: Some(ty_loc),
                    recursive: false,
                });
            }
            Err(()) => success = false,
        }
    }

    (params, success)
}

/// Resolve the return values
pub fn resolve_returns(
    returns: &[(program::Loc, Option<program::Parameter>)],
    file_no: usize,
    contract_no: Option<usize>,
    ns: &mut Namespace,
    diagnostics: &mut Diagnostics,
) -> (Vec<Parameter>, bool) {
    let mut resolved_returns = Vec::new();
    let mut success = true;

    for (loc, r) in returns {
        let r = match r {
            Some(r) => r,
            None => {
                diagnostics.push(Diagnostic::error(*loc, "missing return type".to_owned()));
                success = false;
                continue;
            }
        };

        let mut ty_loc = r.ty.loc();

        match ns.resolve_type(file_no, contract_no, &r.ty, diagnostics) {
            Ok(ty) => {
                resolved_returns.push(Parameter {
                    loc: *loc,
                    id: r.name.clone(),
                    ty,
                    ty_loc: Some(ty_loc),
                    recursive: false,
                });
            }
            Err(()) => success = false,
        }
    }

    (resolved_returns, success)
}

#[test]
fn signatures() {
    use super::*;

    let mut ns = Namespace::new();

    ns.contracts
        .push(ast::Contract::new("bar", program::Loc::Implicit));

    let fdecl = Function::new(
        program::Loc::Implicit,
        "foo".to_owned(),
        None,
        vec![
            Parameter {
                loc: program::Loc::Implicit,
                id: None,
                ty: Type::Uint(32),
                ty_loc: None,
                recursive: false,
            },
            Parameter {
                loc: program::Loc::Implicit,
                id: None,
                ty: Type::Uint(64),
                ty_loc: None,
                recursive: false,
            },
        ],
        Vec::new(),
        &ns,
    );

    assert_eq!(fdecl.signature, "foo(u32,u64)");
}
