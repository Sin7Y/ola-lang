// SPDX-License-Identifier: Apache-2.0

use super::{
    ast::{
        Diagnostic, Expression, Function, Namespace, Parameter, Symbol,
        Type,
    },
    diagnostics::Diagnostics,
    expression::{expression, ExprContext, ResolveTo},
    Symtable,
};

use ola_parser::{program, program::{CodeLocation, OptionalCodeLocation},
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

    // The parser allows constructors to have return values. This is so that we can give a
    // nicer error message than "returns unexpected"
    match func.ty {
        program::FunctionTy::Function => {
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
        }
        program::FunctionTy::Constructor => {
            if !func.returns.is_empty() {
                ns.diagnostics.push(Diagnostic::error(
                    func.loc,
                    "constructor cannot have return values".to_string(),
                ));
                return None;
            }
            // Allow setting a name in Substrate to be used during metadata generation.
            if func.name.is_some() && !ns.target.is_substrate() {
                ns.diagnostics.push(Diagnostic::error(
                    func.loc,
                    "constructor cannot have a name".to_string(),
                ));
                return None;
            }
        }
        program::FunctionTy::Fallback | program::FunctionTy::Receive => {
            if !func.returns.is_empty() {
                ns.diagnostics.push(Diagnostic::error(
                    func.loc,
                    format!("{} function cannot have return values", func.ty),
                ));
                success = false;
            }
            if !func.params.is_empty() {
                ns.diagnostics.push(Diagnostic::error(
                    func.loc,
                    format!("{} function cannot have parameters", func.ty),
                ));
                success = false;
            }
            if func.name.is_some() {
                ns.diagnostics.push(Diagnostic::error(
                    func.loc,
                    format!("{} function cannot have a name", func.ty),
                ));
                return None;
            }
        }
        program::FunctionTy::Modifier => {
            if !func.returns.is_empty() {
                ns.diagnostics.push(Diagnostic::error(
                    func.loc,
                    "constructor cannot have return values".to_string(),
                ));
                return None;
            }
        }
    }

    if let Some(loc) = func.return_not_returns {
        ns.diagnostics.push(Diagnostic::error(
            loc,
            "'return' unexpected. Did you mean 'returns'?".to_string(),
        ));
        success = false;
    }

    let mut mutability: Option<program::Mutability> = None;
    let mut visibility: Option<program::Visibility> = None;
    let mut is_virtual: Option<program::Loc> = None;
    let mut is_override: Option<(program::Loc, Vec<usize>)> = None;
    let mut has_selector: Option<&program::Expression> = None;

    for a in &func.attributes {
        match &a {
            program::FunctionAttribute::Immutable(loc) => {
                ns.diagnostics.push(Diagnostic::error(
                    *loc,
                    "function cannot be declared 'immutable'".to_string(),
                ));
                success = false;
                continue;
            }
            program::FunctionAttribute::Mutability(m) => {
                if let Some(e) = &mutability {
                    ns.diagnostics.push(Diagnostic::error_with_note(
                        m.loc(),
                        format!("function redeclared '{}'", m),
                        e.loc(),
                        format!("location of previous declaration of '{}'", e),
                    ));
                    success = false;
                    continue;
                }

                if let program::Mutability::Constant(loc) = m {
                    ns.diagnostics.push(Diagnostic::warning(
                        *loc,
                        "'constant' is deprecated. Use 'view' instead".to_string(),
                    ));

                    mutability = Some(program::Mutability::View(*loc));
                } else {
                    mutability = Some(m.clone());
                }
            }
            program::FunctionAttribute::Visibility(v) => {
                if let Some(e) = &visibility {
                    ns.diagnostics.push(Diagnostic::error_with_note(
                        v.loc().unwrap(),
                        format!("function redeclared '{}'", v),
                        e.loc().unwrap(),
                        format!("location of previous declaration of '{}'", e),
                    ));
                    success = false;
                    continue;
                }

                visibility = Some(v.clone());
            }
            program::FunctionAttribute::Virtual(loc) => {
                if let Some(prev_loc) = &is_virtual {
                    ns.diagnostics.push(Diagnostic::error_with_note(
                        *loc,
                        "function redeclared 'virtual'".to_string(),
                        *prev_loc,
                        "location of previous declaration of 'virtual'".to_string(),
                    ));
                    success = false;
                    continue;
                }

                is_virtual = Some(*loc);
            }
            program::FunctionAttribute::NameValue(loc, name, value) => {
                if name.name != "selector" {
                    ns.diagnostics.push(Diagnostic::error(
                        name.loc,
                        format!("function attribute '{}' not supported", name.name),
                    ));
                    success = false;
                } else if let Some(prev_loc) = &has_selector {
                    ns.diagnostics.push(Diagnostic::error_with_note(
                        *loc,
                        "function redeclared attribute 'selector'".to_string(),
                        prev_loc.loc(),
                        "location of previous declaration of 'selector'".to_string(),
                    ));
                    success = false;
                } else {
                    has_selector = Some(value);
                }
            }
            program::FunctionAttribute::Override(loc, bases) => {
                if let Some((prev_loc, _)) = &is_override {
                    ns.diagnostics.push(Diagnostic::error_with_note(
                        *loc,
                        "function redeclared 'override'".to_string(),
                        *prev_loc,
                        "location of previous declaration of 'override'".to_string(),
                    ));
                    success = false;
                    continue;
                }

                let mut list = Vec::new();
                let mut diagnostics = Diagnostics::default();

                for name in bases {
                    if let Ok(no) =
                        ns.resolve_contract_with_namespace(file_no, name, &mut diagnostics)
                    {
                        if list.contains(&no) {
                            diagnostics.push(Diagnostic::error(
                                name.loc,
                                format!("function duplicate override '{}'", name),
                            ));
                        } else if !is_base(no, contract_no, ns) {
                            diagnostics.push(Diagnostic::error(
                                name.loc,
                                format!(
                                    "override '{}' is not a base contract of '{}'",
                                    name, ns.contracts[contract_no].name
                                ),
                            ));
                        } else {
                            list.push(no);
                        }
                    }
                }

                ns.diagnostics.extend(diagnostics);

                is_override = Some((*loc, list));
            }
            program::FunctionAttribute::BaseOrModifier(loc, _) => {
                // We can only fully resolve the base constructors arguments
                // once we have resolved all the constructors, this is not done here yet
                // so we fully resolve these along with the constructor body
                if func.ty != program::FunctionTy::Constructor && func.ty != program::FunctionTy::Function {
                    ns.diagnostics.push(Diagnostic::error(
                        *loc,
                        format!(
                            "function modifiers or base contracts are not allowed on {}",
                            func.ty
                        ),
                    ));
                }
            }
            program::FunctionAttribute::Error(_) => unreachable!(),
        }
    }

    let visibility = match visibility {
        Some(v) => {
            if func.ty == program::FunctionTy::Modifier {
                ns.diagnostics.push(Diagnostic::error(
                    v.loc().unwrap(),
                    format!("'{}': modifiers can not have visibility", v),
                ));

                program::Visibility::Internal(v.loc())
            } else if func.ty == program::FunctionTy::Constructor {
                ns.diagnostics.push(Diagnostic::warning(
                    v.loc().unwrap(),
                    format!("'{}': visibility for constructors is ignored", v),
                ));

                program::Visibility::Public(v.loc())
            } else {
                v
            }
        }
        None => {
            match func.ty {
                program::FunctionTy::Constructor => program::Visibility::Public(None),
                program::FunctionTy::Modifier => program::Visibility::Internal(None),
                _ => {
                    ns.diagnostics.push(Diagnostic::error(
                        func.loc,
                        "no visibility specified".to_string(),
                    ));

                    success = false;
                    // continue processing while assuming it's a public
                    program::Visibility::Public(None)
                }
            }
        }
    };

    if let Some(m) = &mutability {
        if func.ty == program::FunctionTy::Modifier {
            ns.diagnostics.push(Diagnostic::error(
                m.loc(),
                "modifier cannot have mutability specifier".to_string(),
            ));
            success = false;
            mutability = None;
        }
    }

    // Reference types can't be passed through the ABI encoder/decoder, so
    // storage parameters/returns are only allowed in internal/private functions
    let storage_allowed = match visibility {
        program::Visibility::Internal(_) | program::Visibility::Private(_) => {
            if let Some(program::Mutability::Payable(loc)) = mutability {
                ns.diagnostics.push(Diagnostic::error(
                    loc,
                    "internal or private function cannot be payable".to_string(),
                ));
                success = false;
            }
            true
        }
        program::Visibility::Public(_) | program::Visibility::External(_) => {
            // library function abi is special. Storage vars are allowed
            ns.contracts[contract_no].is_library()
        }
    };

    let mut diagnostics = Diagnostics::default();

    let selector = if let Some(selector) = has_selector {
        if func.ty != program::FunctionTy::Function
            && (!ns.target.is_substrate() || func.ty != program::FunctionTy::Constructor)
        {
            ns.diagnostics.push(Diagnostic::error(
                selector.loc(),
                format!("overriding selector not permitted on {}", func.ty),
            ));

            None
        } else if !matches!(
            visibility,
            program::Visibility::External(_) | program::Visibility::Public(_)
        ) {
            ns.diagnostics.push(Diagnostic::error(
                selector.loc(),
                format!(
                    "overriding selector only permitted on 'public' or 'external' function, not '{}'",
                    visibility
                ),
            ));

            None
        } else {
            let context = ExprContext {
                file_no,
                constant: true,
                ..Default::default()
            };

            match expression(
                selector,
                &context,
                ns,
                &mut Symtable::new(),
                &mut diagnostics,
                ResolveTo::Unknown,
            ) {
                Ok(Expression::BytesLiteral(_, _, v)) => {
                    if ns.target != Target::Solana && v.len() != 4 {
                        ns.diagnostics.push(Diagnostic::error(
                            selector.loc(),
                            format!("selector is {} bytes, 4 bytes expected", v.len()),
                        ));
                        success = false;
                        None
                    } else {
                        Some(v)
                    }
                }
                Ok(_) => {
                    ns.diagnostics.push(Diagnostic::error(
                        selector.loc(),
                        "hex literal of the form 'hex\"1234abcdef\"' expected".to_string(),
                    ));
                    success = false;
                    None
                }
                Err(_) => {
                    success = false;
                    None
                }
            }
        }
    } else {
        None
    };

    let (params, params_success) = resolve_params(
        &func.params,
        storage_allowed,
        file_no,
        Some(contract_no),
        ns,
        &mut diagnostics,
    );

    let (returns, returns_success) = resolve_returns(
        &func.returns,
        storage_allowed,
        file_no,
        Some(contract_no),
        ns,
        &mut diagnostics,
    );

    ns.diagnostics.extend(diagnostics);

    if ns.contracts[contract_no].is_interface() {
        if func.ty == program::FunctionTy::Constructor {
            ns.diagnostics.push(Diagnostic::error(
                func.loc,
                "constructor not allowed in an interface".to_string(),
            ));
            success = false;
        } else if func.body.is_some() {
            ns.diagnostics.push(Diagnostic::error(
                func.loc,
                "function in an interface cannot have a body".to_string(),
            ));
            success = false;
        } else if let program::Visibility::External(_) = visibility {
            // ok
        } else {
            ns.diagnostics.push(Diagnostic::error(
                func.loc,
                "functions must be declared 'external' in an interface".to_string(),
            ));
            success = false;
        }
    } else if ns.contracts[contract_no].is_library() {
        if func.ty != program::FunctionTy::Function {
            ns.diagnostics.push(Diagnostic::error(
                func.loc,
                format!("{} not allowed in a library", func.ty),
            ));
            success = false;
        } else if func.body.is_none() {
            ns.diagnostics.push(Diagnostic::error(
                func.loc,
                "function in a library must have a body".to_string(),
            ));
            success = false;
        } else if let Some((loc, _)) = is_override {
            ns.diagnostics.push(Diagnostic::error(
                loc,
                "function in a library cannot override".to_string(),
            ));
            success = false;
        } else if let Some(program::Mutability::Payable(_)) = mutability {
            ns.diagnostics.push(Diagnostic::error(
                func.loc,
                "function in a library cannot be payable".to_string(),
            ));
            success = false;
        }
    } else if func.ty == program::FunctionTy::Constructor && is_virtual.is_some() {
        ns.diagnostics.push(Diagnostic::error(
            func.loc,
            "constructors cannot be declared 'virtual'".to_string(),
        ));
    }

    // all functions in an interface are implicitly virtual
    let is_virtual = if ns.contracts[contract_no].is_interface() {
        if let Some(loc) = is_virtual {
            ns.diagnostics.push(Diagnostic::warning(
                loc,
                "functions in an interface are implicitly virtual".to_string(),
            ));
        }

        true
    } else if ns.contracts[contract_no].is_library() {
        if let Some(loc) = is_virtual {
            ns.diagnostics.push(Diagnostic::error(
                loc,
                "functions in a library cannot be virtual".to_string(),
            ));
        }

        false
    } else {
        is_virtual.is_some()
    };

    if !is_virtual && func.body.is_none() {
        ns.diagnostics.push(Diagnostic::error(
            func.loc,
            "function with no body missing 'virtual'. This was permitted in older versions of the Solidity language, please update.".to_string(),
        ));
        success = false;
    }

    if let program::Visibility::Private(_) = visibility {
        if is_virtual {
            ns.diagnostics.push(Diagnostic::error(
                func.loc,
                "function marked 'virtual' cannot also be 'private'".to_string(),
            ));
            success = false;
        }
    }

    if !success || !returns_success || !params_success {
        return None;
    }

    let name = func
        .name
        .as_ref()
        .map(|s| s.name.as_str())
        .unwrap_or_else(|| {
            if ns.target.is_substrate() && func.ty == program::FunctionTy::Constructor {
                "new"
            } else {
                ""
            }
        })
        .to_owned();

    let bases: Vec<String> = contract
        .base
        .iter()
        .map(|base| format!("{}", base.name))
        .collect();

    let doc = resolve_tags(
        func.loc.file_no(),
        "function",
        tags,
        Some(&params),
        Some(&returns),
        Some(&bases),
        ns,
    );

    let mut fdecl = Function::new(
        func.loc,
        name,
        Some(contract_no),
        params,
        returns,
        ns,
    );

    fdecl.has_body = func.body.is_some();
    fdecl.selector = selector;

    if func.ty == program::FunctionTy::Constructor {
        // In the eth solidity only one constructor is allowed
        if ns.target == Target::EVM {
            if let Some(prev_func_no) = ns.contracts[contract_no]
                .functions
                .iter()
                .find(|func_no| ns.functions[**func_no].is_constructor())
            {
                let prev_loc = ns.functions[*prev_func_no].loc;

                ns.diagnostics.push(Diagnostic::error_with_note(
                    func.loc,
                    "constructor already defined".to_string(),
                    prev_loc,
                    "location of previous definition".to_string(),
                ));
                return None;
            }
        } else {
            let payable = fdecl.is_payable();

            if let Some(prev_func_no) = ns.contracts[contract_no].functions.iter().find(|func_no| {
                let f = &ns.functions[**func_no];

                f.is_constructor() && f.is_payable() != payable
            }) {
                let prev_loc = ns.functions[*prev_func_no].loc;

                ns.diagnostics.push(Diagnostic::error_with_note(
                    func.loc,
                    "all constructors should be defined 'payable' or not".to_string(),
                    prev_loc,
                    "location of previous definition".to_string(),
                ));
                return None;
            }
        }

        match fdecl.mutability {
            Mutability::Pure(loc) => {
                ns.diagnostics.push(Diagnostic::error(
                    loc,
                    "constructor cannot be declared pure".to_string(),
                ));
                return None;
            }
            Mutability::View(loc) => {
                ns.diagnostics.push(Diagnostic::error(
                    loc,
                    "constructor cannot be declared view".to_string(),
                ));
                return None;
            }
            _ => (),
        }

        for prev_func_no in &ns.contracts[contract_no].functions {
            let v = &ns.functions[*prev_func_no];

            if v.is_constructor() && v.signature == fdecl.signature {
                ns.diagnostics.push(Diagnostic::error_with_note(
                    func.loc,
                    "constructor with this signature already exists".to_string(),
                    v.loc,
                    "location of previous definition".to_string(),
                ));

                return None;
            }
        }

        let pos = ns.functions.len();

        ns.contracts[contract_no].functions.push(pos);
        ns.functions.push(fdecl);

        Some(pos)
    } else if func.ty == program::FunctionTy::Receive || func.ty == program::FunctionTy::Fallback {
        if func.ty == program::FunctionTy::Receive && ns.target == Target::Solana {
            ns.diagnostics.push(Diagnostic::error(
                func.loc,
                format!("target {} does not support receive() functions, see https://solang.readthedocs.io/en/latest/language/functions.html#fallback-and-receive-function", ns.target),
            ));
        } else {
            if let Some(prev_func_no) = ns.contracts[contract_no]
                .functions
                .iter()
                .find(|func_no| ns.functions[**func_no].ty == func.ty)
            {
                let prev_loc = ns.functions[*prev_func_no].loc;

                ns.diagnostics.push(Diagnostic::error_with_note(
                    func.loc,
                    format!("{} function already defined", func.ty),
                    prev_loc,
                    "location of previous definition".to_string(),
                ));
                return None;
            }

            if let program::Visibility::External(_) = fdecl.visibility {
                // ok
            } else {
                ns.diagnostics.push(Diagnostic::error(
                    func.loc,
                    format!("{} function must be declared external", func.ty),
                ));
                return None;
            }

            if fdecl.is_payable() {
                if func.ty == program::FunctionTy::Fallback {
                    ns.diagnostics.push(Diagnostic::error(
                    func.loc,
                    format!("{} function must not be declare payable, use 'receive() external payable' instead", func.ty),
                ));
                    return None;
                }
            } else if func.ty == program::FunctionTy::Receive {
                ns.diagnostics.push(Diagnostic::error(
                    func.loc,
                    format!("{} function must be declared payable", func.ty),
                ));
                return None;
            }
        }

        let pos = ns.functions.len();

        ns.contracts[contract_no].functions.push(pos);
        ns.functions.push(fdecl);

        Some(pos)
    } else {
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
                format!("overloaded {} with this signature already exist", func.ty),
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
        resolve_params(&func.params, true, file_no, None, ns, &mut diagnostics);

    let (returns, returns_success) =
        resolve_returns(&func.returns, true, file_no, None, ns, &mut diagnostics);

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

    let doc = resolve_tags(
        func.loc.file_no(),
        "function",
        tags,
        Some(&params),
        Some(&returns),
        None,
        ns,
    );

    let mut fdecl = Function::new(
        func.loc,
        name,
        None,
        params,
        returns,
        ns,
    );

    fdecl.has_body = true;

    let id = func.name.as_ref().unwrap();

    if let Some(prev) = ns.functions.iter().find(|f| fdecl.signature == f.signature) {
        ns.diagnostics.push(Diagnostic::error_with_note(
            func.loc,
            format!("overloaded {} with this signature already exist", func.ty),
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
    is_internal: bool,
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

        match ns.resolve_type(file_no, contract_no, false, &p.ty, diagnostics) {
            Ok(ty) => {
                if !is_internal {
                    if ty.contains_internal_function(ns) {
                        diagnostics.push(Diagnostic::error(
                        p.ty.loc(),
                        "parameter of type 'function internal' not allowed public or external functions".to_string(),
                    ));
                        success = false;
                    }

                    if let Some(ty) = ty.contains_builtins(ns, &StructType::AccountInfo) {
                        let message = format!(
                            "parameter of type '{}' not alowed in public or external functions",
                            ty.to_string(ns)
                        );
                        ns.diagnostics.push(Diagnostic::error(p.ty.loc(), message));
                        success = false
                    }
                }

                let ty = if !ty.can_have_data_location() {
                    if let Some(storage) = &p.storage {
                        diagnostics.push(Diagnostic::error(
                            storage.loc(),
                                format!("data location '{}' can only be specified for array, struct or mapping",
                                storage)
                            ));
                        success = false;
                    }

                    ty
                } else if let Some(program::StorageLocation::Storage(loc)) = p.storage {
                    if !is_internal {
                        diagnostics.push(Diagnostic::error(
                            loc,
                            "parameter of type 'storage' not allowed public or external functions"
                                .to_string(),
                        ));
                        success = false;
                    }

                    ty_loc.use_end_from(&loc);

                    Type::StorageRef(false, Box::new(ty))
                } else {
                    if ty.contains_mapping(ns) {
                        diagnostics.push(Diagnostic::error(
                            p.ty.loc(),
                            "parameter with mapping type must be of type 'storage'".to_string(),
                        ));
                        success = false;
                    }

                    if !ty.fits_in_memory(ns) {
                        diagnostics.push(Diagnostic::error(
                            p.ty.loc(),
                            String::from("type is too large to fit into memory"),
                        ));
                        success = false;
                    }

                    ty
                };

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
    is_internal: bool,
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

        match ns.resolve_type(file_no, contract_no, false, &r.ty, diagnostics) {
            Ok(ty) => {
                if !is_internal {
                    if ty.contains_internal_function(ns) {
                        diagnostics.push(Diagnostic::error(
                        r.ty.loc(),
                        "return type 'function internal' not allowed in public or external functions"
                            .to_string(),
                    ));
                        success = false;
                    }

                    if let Some(ty) = ty.contains_builtins(ns, &StructType::AccountInfo) {
                        let message = format!(
                            "return type '{}' not allowed in public or external functions",
                            ty.to_string(ns)
                        );
                        ns.diagnostics.push(Diagnostic::error(r.ty.loc(), message));
                        success = false
                    }
                }
                let ty = if !ty.can_have_data_location() {
                    if let Some(storage) = &r.storage {
                        diagnostics.push(Diagnostic::error(
                            storage.loc(),
                                format!("data location '{}' can only be specified for array, struct or mapping",
                                storage)
                            ));
                        success = false;
                    }

                    ty
                } else {
                    match r.storage {
                        Some(program::StorageLocation::Storage(loc)) => {
                            if !is_internal {
                                diagnostics.push(Diagnostic::error(
                                    loc,
                                    "return type of type 'storage' not allowed public or external functions"
                                        .to_string(),
                                ));
                                success = false;
                            }

                            ty_loc.use_end_from(&loc);

                            Type::StorageRef(false, Box::new(ty))
                        }
                        _ => {
                            if ty.contains_mapping(ns) {
                                diagnostics.push(Diagnostic::error(
                                    r.ty.loc(),
                                    "return type containing mapping must be of type 'storage'"
                                        .to_string(),
                                ));
                                success = false;
                            }

                            if !ty.fits_in_memory(ns) {
                                diagnostics.push(Diagnostic::error(
                                    r.ty.loc(),
                                    String::from("type is too large to fit into memory"),
                                ));
                                success = false;
                            }

                            ty
                        }
                    }
                };

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

    let mut ns = Namespace::new(Target::EVM);

    ns.contracts.push(ast::Contract::new(
        "bar",
        program::ContractTy::Contract(program::Loc::Implicit),
        Vec::new(),
        program::Loc::Implicit,
    ));

    let fdecl = Function::new(
        program::Loc::Implicit,
        "foo".to_owned(),
        None,
        vec![],
        program::FunctionTy::Function,
        None,
        program::Visibility::Public(None),
        vec![
            Parameter {
                loc: program::Loc::Implicit,
                id: None,
                ty: Type::Uint(8),
                ty_loc: None,
                indexed: false,
                readonly: false,
                recursive: false,
            },
            Parameter {
                loc: program::Loc::Implicit,
                id: None,
                ty: Type::Address(false),
                ty_loc: None,
                indexed: false,
                readonly: false,
                recursive: false,
            },
        ],
        Vec::new(),
        &ns,
    );

    assert_eq!(fdecl.signature, "foo(uint8,address)");
}
