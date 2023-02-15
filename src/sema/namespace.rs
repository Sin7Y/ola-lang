// SPDX-License-Identifier: Apache-2.0

use super::{
    ast::{ArrayLength, Diagnostic, Namespace, Note, Parameter, RetrieveType, Symbol, Type},
    builtin,
    diagnostics::Diagnostics,
    eval::eval_const_number,
    expression::{expression, ExprContext, ResolveTo},
    symtable::Symtable,
    ArrayDimension,
};
use num_bigint::BigInt;
use num_traits::Signed;
use num_traits::Zero;
use ola_parser::{program, program::CodeLocation};
use std::collections::HashMap;

impl Namespace {
    /// Create a namespace and populate with the parameters for the target
    pub fn new() -> Self {
        let ns = Namespace {
            files: Vec::new(),
            enums: Vec::new(),
            structs: Vec::new(),
            contracts: Vec::new(),
            user_types: Vec::new(),
            functions: Vec::new(),
            constants: Vec::new(),
            address_length: 0,
            variable_symbols: HashMap::new(),
            function_symbols: HashMap::new(),
            diagnostics: Diagnostics::default(),
            next_id: 0,
        };

        ns
    }

    /// Add symbol to symbol table; either returns true for success, or adds an
    /// appropriate error
    pub fn add_symbol(
        &mut self,
        file_no: usize,
        contract_no: Option<usize>,
        id: &program::Identifier,
        symbol: Symbol,
    ) -> bool {
        if builtin::is_reserved(&id.name) {
            self.diagnostics.push(Diagnostic::error(
                id.loc,
                format!("'{}' shadows name of a builtin", id.name),
            ));

            return false;
        }

        if let Some(Symbol::Function(v)) =
            self.function_symbols
                .get(&(file_no, contract_no, id.name.to_owned()))
        {
            let notes = v
                .iter()
                .map(|(pos, _)| Note {
                    loc: *pos,
                    message: "location of previous definition".to_owned(),
                })
                .collect();

            self.diagnostics.push(Diagnostic::error_with_notes(
                id.loc,
                format!("{} is already defined as a function", id.name),
                notes,
            ));

            return false;
        }

        if let Some(sym) = self
            .variable_symbols
            .get(&(file_no, contract_no, id.name.to_owned()))
        {
            match sym {
                Symbol::Contract(c, _) => {
                    self.diagnostics.push(Diagnostic::error_with_note(
                        id.loc,
                        format!("{} is already defined as a contract name", id.name),
                        *c,
                        "location of previous definition".to_string(),
                    ));
                }
                Symbol::Enum(c, _) => {
                    self.diagnostics.push(Diagnostic::error_with_note(
                        id.loc,
                        format!("{} is already defined as an enum", id.name),
                        *c,
                        "location of previous definition".to_string(),
                    ));
                }
                Symbol::Struct(c, _) => {
                    self.diagnostics.push(Diagnostic::error_with_note(
                        id.loc,
                        format!("{} is already defined as a struct", id.name),
                        *c,
                        "location of previous definition".to_string(),
                    ));
                }
                Symbol::Variable(c, _, _) => {
                    self.diagnostics.push(Diagnostic::error_with_note(
                        id.loc,
                        format!("{} is already defined as a contract variable", id.name),
                        *c,
                        "location of previous definition".to_string(),
                    ));
                }
                Symbol::Import(loc, _) => {
                    self.diagnostics.push(Diagnostic::error_with_note(
                        id.loc,
                        format!("{} is already defined as an import", id.name),
                        *loc,
                        "location of previous definition".to_string(),
                    ));
                }
                Symbol::UserType(loc, _) => {
                    self.diagnostics.push(Diagnostic::error_with_note(
                        id.loc,
                        format!("{} is already defined as an user type", id.name),
                        *loc,
                        "location of previous definition".to_string(),
                    ));
                }
                Symbol::Function(_) => unreachable!(),
            }

            return false;
        }

        // if there is nothing on the contract level
        if contract_no.is_some() {
            if let Some(Symbol::Function(v)) =
                self.function_symbols
                    .get(&(file_no, None, id.name.to_owned()))
            {
                let notes = v
                    .iter()
                    .map(|(pos, _)| Note {
                        loc: *pos,
                        message: "location of previous definition".to_owned(),
                    })
                    .collect();

                self.diagnostics.push(Diagnostic::warning_with_notes(
                    id.loc,
                    format!("{} is already defined as a function", id.name),
                    notes,
                ));
            }

            if let Some(sym) = self
                .variable_symbols
                .get(&(file_no, None, id.name.to_owned()))
            {
                match sym {
                    Symbol::Contract(c, _) => {
                        self.diagnostics.push(Diagnostic::warning_with_note(
                            id.loc,
                            format!("{} is already defined as a contract name", id.name),
                            *c,
                            "location of previous definition".to_string(),
                        ));
                    }
                    Symbol::Enum(c, _) => {
                        self.diagnostics.push(Diagnostic::warning_with_note(
                            id.loc,
                            format!("{} is already defined as an enum", id.name),
                            *c,
                            "location of previous definition".to_string(),
                        ));
                    }
                    Symbol::Struct(c, _) => {
                        self.diagnostics.push(Diagnostic::warning_with_note(
                            id.loc,
                            format!("{} is already defined as a struct", id.name),
                            *c,
                            "location of previous definition".to_string(),
                        ));
                    }
                    Symbol::Variable(c, _, _) => {
                        self.diagnostics.push(Diagnostic::warning_with_note(
                            id.loc,
                            format!("{} is already defined as a contract variable", id.name),
                            *c,
                            "location of previous definition".to_string(),
                        ));
                    }
                    Symbol::Function(_) => unreachable!(),
                    Symbol::Import(loc, _) => {
                        self.diagnostics.push(Diagnostic::warning_with_note(
                            id.loc,
                            format!("{} is already defined as an import", id.name),
                            *loc,
                            "location of previous definition".to_string(),
                        ));
                    }
                    Symbol::UserType(loc, _) => {
                        self.diagnostics.push(Diagnostic::warning_with_note(
                            id.loc,
                            format!("{} is already defined as an user type", id.name),
                            *loc,
                            "location of previous definition".to_string(),
                        ));
                    }
                }
            }
        }

        if let Symbol::Function(_) = &symbol {
            self.function_symbols
                .insert((file_no, contract_no, id.name.to_string()), symbol);
        } else {
            self.variable_symbols
                .insert((file_no, contract_no, id.name.to_string()), symbol);
        }

        true
    }

    /// Resolve enum by name
    pub fn resolve_enum(
        &self,
        file_no: usize,
        contract_no: Option<usize>,
        id: &program::Identifier,
    ) -> Option<usize> {
        if let Some(Symbol::Enum(_, n)) =
            self.variable_symbols
                .get(&(file_no, contract_no, id.name.to_owned()))
        {
            return Some(*n);
        }

        if contract_no.is_some() {
            if let Some(Symbol::Enum(_, n)) =
                self.variable_symbols
                    .get(&(file_no, None, id.name.to_owned()))
            {
                return Some(*n);
            }
        }

        None
    }

    /// Resolve a contract name
    pub fn resolve_contract(&self, file_no: usize, id: &program::Identifier) -> Option<usize> {
        if let Some(Symbol::Contract(_, n)) =
            self.variable_symbols
                .get(&(file_no, None, id.name.to_owned()))
        {
            return Some(*n);
        }

        None
    }

    pub fn wrong_symbol(sym: Option<&Symbol>, id: &program::Identifier) -> Diagnostic {
        match sym {
            None => Diagnostic::decl_error(id.loc, format!("'{}' not found", id.name)),
            Some(Symbol::Enum(..)) => {
                Diagnostic::decl_error(id.loc, format!("'{}' is an enum", id.name))
            }
            Some(Symbol::Struct(..)) => {
                Diagnostic::decl_error(id.loc, format!("'{}' is a struct", id.name))
            }
            Some(Symbol::Function(_)) => {
                Diagnostic::decl_error(id.loc, format!("'{}' is a function", id.name))
            }
            Some(Symbol::Contract(..)) => {
                Diagnostic::decl_error(id.loc, format!("'{}' is a contract", id.name))
            }
            Some(Symbol::Import(..)) => {
                Diagnostic::decl_error(id.loc, format!("'{}' is an import", id.name))
            }
            Some(Symbol::UserType(..)) => {
                Diagnostic::decl_error(id.loc, format!("'{}' is an user type", id.name))
            }
            Some(Symbol::Variable(..)) => {
                Diagnostic::decl_error(id.loc, format!("'{}' is a contract variable", id.name))
            }
        }
    }

    /// Resolve contract variable or function. Specify whether you wish to
    /// resolve a function or a variable; this will change the lookup order.
    /// A public contract will have both a accesssor function and variable,
    /// and the accessor function may show else where in the base contracts
    /// a function without body.
    pub fn resolve_var(
        &self,
        file_no: usize,
        contract_no: Option<usize>,
        id: &program::Identifier,
        function_first: bool,
    ) -> Option<&Symbol> {
        let func = || {
            let s = self
                .function_symbols
                .get(&(file_no, contract_no, id.name.to_owned()));

            s.or_else(|| {
                self.function_symbols
                    .get(&(file_no, None, id.name.to_owned()))
            })
        };

        let var = || {
            let s = self
                .variable_symbols
                .get(&(file_no, contract_no, id.name.to_owned()));

            s.or_else(|| {
                self.variable_symbols
                    .get(&(file_no, None, id.name.to_owned()))
            })
        };

        if function_first {
            func().or_else(var)
        } else {
            var().or_else(func)
        }
    }

    /// Check if an name would shadow an existing symbol
    pub fn check_shadowing(
        &mut self,
        file_no: usize,
        contract_no: Option<usize>,
        id: &program::Identifier,
    ) {
        if builtin::is_reserved(&id.name) {
            self.diagnostics.push(Diagnostic::warning(
                id.loc,
                format!("'{}' shadows name of a builtin", id.name),
            ));
            return;
        }

        let s = self
            .variable_symbols
            .get(&(file_no, contract_no, id.name.to_owned()))
            .or_else(|| {
                self.function_symbols
                    .get(&(file_no, contract_no, id.name.to_owned()))
            })
            .or_else(|| {
                self.variable_symbols
                    .get(&(file_no, None, id.name.to_owned()))
            })
            .or_else(|| {
                self.function_symbols
                    .get(&(file_no, None, id.name.to_owned()))
            });

        match s {
            Some(Symbol::Enum(loc, _)) => {
                let loc = *loc;
                self.diagnostics.push(Diagnostic::warning_with_note(
                    id.loc,
                    format!("declaration of '{}' shadows enum definition", id.name),
                    loc,
                    "previous definition of enum".to_string(),
                ));
            }
            Some(Symbol::Struct(loc, _)) => {
                let loc = *loc;
                self.diagnostics.push(Diagnostic::warning_with_note(
                    id.loc,
                    format!("declaration of '{}' shadows struct definition", id.name),
                    loc,
                    "previous definition of struct".to_string(),
                ));
            }
            Some(Symbol::Function(v)) => {
                let notes = v
                    .iter()
                    .map(|(pos, _)| Note {
                        loc: *pos,
                        message: "previous declaration of function".to_owned(),
                    })
                    .collect();
                self.diagnostics.push(Diagnostic::warning_with_notes(
                    id.loc,
                    format!("declaration of '{}' shadows function", id.name),
                    notes,
                ));
            }
            Some(Symbol::Variable(loc, _, _)) => {
                let loc = *loc;
                self.diagnostics.push(Diagnostic::warning_with_note(
                    id.loc,
                    format!("declaration of '{}' shadows state variable", id.name),
                    loc,
                    "previous declaration of state variable".to_string(),
                ));
            }
            Some(Symbol::Contract(loc, _)) => {
                let loc = *loc;
                self.diagnostics.push(Diagnostic::warning_with_note(
                    id.loc,
                    format!("declaration of '{}' shadows contract name", id.name),
                    loc,
                    "previous declaration of contract name".to_string(),
                ));
            }
            Some(Symbol::UserType(loc, _)) => {
                let loc = *loc;
                self.diagnostics.push(Diagnostic::warning_with_note(
                    id.loc,
                    format!("declaration of '{}' shadows type", id.name),
                    loc,
                    "previous declaration of type".to_string(),
                ));
            }
            Some(Symbol::Import(loc, _)) => {
                let loc = *loc;
                self.diagnostics.push(Diagnostic::warning_with_note(
                    id.loc,
                    format!("declaration of '{}' shadows import", id.name),
                    loc,
                    "previous declaration of import".to_string(),
                ));
            }
            None => (),
        }
    }

    /// Resolve the parsed data type. The type can be a primitive, enum and also
    /// an arrays. The type for address payable is "address payable" used as
    /// a type, and "payable" when casting. So, we need to know what we are
    /// resolving for.
    pub fn resolve_type(
        &mut self,
        file_no: usize,
        contract_no: Option<usize>,
        id: &program::Expression,
        diagnostics: &mut Diagnostics,
    ) -> Result<Type, ()> {
        let resolve_dimensions = |ast_dimensions: &[Option<(program::Loc, BigInt)>],
                                  diagnostics: &mut Diagnostics| {
            let mut dimensions = Vec::new();

            for d in ast_dimensions.iter().rev() {
                if let Some((loc, n)) = d {
                    if n.is_zero() {
                        diagnostics.push(Diagnostic::decl_error(
                            *loc,
                            "zero size array not permitted".to_string(),
                        ));
                        return Err(());
                    } else if n.is_negative() {
                        diagnostics.push(Diagnostic::decl_error(
                            *loc,
                            "negative size of array declared".to_string(),
                        ));
                        return Err(());
                    } else if n > &u32::MAX.into() {
                        let msg = format!(
                            "array dimension of {} exceeds the maximum of 4294967295 on Substrate",
                            n
                        );
                        diagnostics.push(Diagnostic::decl_error(*loc, msg));
                        return Err(());
                    }
                    dimensions.push(ArrayLength::Fixed(n.clone()));
                } else {
                    dimensions.push(ArrayLength::Dynamic);
                }
            }

            Ok(dimensions)
        };

        let (namespace, id, dimensions) =
            self.expr_to_type(file_no, contract_no, id, diagnostics)?;

        if let program::Expression::Type(_, ty) = &id {
            assert!(namespace.is_empty());

            let ty = Type::from(ty);

            return if dimensions.is_empty() {
                Ok(ty)
            } else {
                Ok(Type::Array(
                    Box::new(ty),
                    resolve_dimensions(&dimensions, diagnostics)?,
                ))
            };
        }

        let id = match id {
            program::Expression::Variable(id) => id,
            _ => unreachable!(),
        };

        let s = self.resolve_namespace(namespace, file_no, contract_no, &id, diagnostics)?;

        match s {
            None => {
                diagnostics.push(Diagnostic::decl_error(
                    id.loc,
                    format!("type '{}' not found", id.name),
                ));
                Err(())
            }
            Some(Symbol::Enum(_, n)) if dimensions.is_empty() => Ok(Type::Enum(*n)),
            Some(Symbol::Enum(_, n)) => Ok(Type::Array(
                Box::new(Type::Enum(*n)),
                resolve_dimensions(&dimensions, diagnostics)?,
            )),
            Some(Symbol::Struct(_, str_ty)) if dimensions.is_empty() => Ok(Type::Struct(*str_ty)),
            Some(Symbol::Struct(_, str_ty)) => Ok(Type::Array(
                Box::new(Type::Struct(*str_ty)),
                resolve_dimensions(&dimensions, diagnostics)?,
            )),
            Some(Symbol::Contract(_, n)) if dimensions.is_empty() => Ok(Type::Contract(*n)),
            Some(Symbol::Contract(_, n)) => Ok(Type::Array(
                Box::new(Type::Contract(*n)),
                resolve_dimensions(&dimensions, diagnostics)?,
            )),
            Some(Symbol::Function(_)) => {
                diagnostics.push(Diagnostic::decl_error(
                    id.loc,
                    format!("'{}' is a function", id.name),
                ));
                Err(())
            }
            Some(Symbol::Variable(..)) => {
                diagnostics.push(Diagnostic::decl_error(
                    id.loc,
                    format!("'{}' is a contract variable", id.name),
                ));
                Err(())
            }
            Some(Symbol::Import(..)) => {
                diagnostics.push(Diagnostic::decl_error(
                    id.loc,
                    format!("'{}' is an import variable", id.name),
                ));
                Err(())
            }
            Some(Symbol::UserType(_, n)) => Ok(Type::UserType(*n)),
        }
    }

    /// Resolve the type name with the namespace to a symbol
    fn resolve_namespace(
        &self,
        mut namespace: Vec<&program::Identifier>,
        file_no: usize,
        mut contract_no: Option<usize>,
        id: &program::Identifier,
        diagnostics: &mut Diagnostics,
    ) -> Result<Option<&Symbol>, ()> {
        // The leading part of the namespace can be import variables
        let mut import_file_no = file_no;

        while !namespace.is_empty() {
            if let Some(Symbol::Import(_, file_no)) =
                self.variable_symbols
                    .get(&(import_file_no, None, namespace[0].name.clone()))
            {
                import_file_no = *file_no;
                namespace.remove(0);
                contract_no = None;
            } else {
                break;
            }
        }

        if let Some(contract_name) = namespace.get(0) {
            contract_no = match self
                .variable_symbols
                .get(&(import_file_no, None, contract_name.name.clone()))
                .or_else(|| {
                    self.function_symbols
                        .get(&(import_file_no, None, contract_name.name.clone()))
                }) {
                None => {
                    diagnostics.push(Diagnostic::decl_error(
                        contract_name.loc,
                        format!("'{}' not found", contract_name.name),
                    ));
                    return Err(());
                }
                Some(Symbol::Contract(_, n)) => {
                    if namespace.len() > 1 {
                        diagnostics.push(Diagnostic::decl_error(
                            id.loc,
                            format!("'{}' not found", namespace[1].name),
                        ));
                        return Err(());
                    };
                    Some(*n)
                }
                Some(Symbol::Function(_)) => {
                    diagnostics.push(Diagnostic::decl_error(
                        contract_name.loc,
                        format!("'{}' is a function", contract_name.name),
                    ));
                    return Err(());
                }
                Some(Symbol::Variable(..)) => {
                    diagnostics.push(Diagnostic::decl_error(
                        contract_name.loc,
                        format!("'{}' is a contract variable", contract_name.name),
                    ));
                    return Err(());
                }
                Some(Symbol::Struct(..)) => {
                    diagnostics.push(Diagnostic::decl_error(
                        contract_name.loc,
                        format!("'{}' is a struct", contract_name.name),
                    ));
                    return Err(());
                }
                Some(Symbol::Enum(..)) => {
                    diagnostics.push(Diagnostic::decl_error(
                        contract_name.loc,
                        format!("'{}' is an enum variable", contract_name.name),
                    ));
                    return Err(());
                }
                Some(Symbol::UserType(..)) => {
                    diagnostics.push(Diagnostic::decl_error(
                        contract_name.loc,
                        format!("'{}' is an user type", contract_name.name),
                    ));
                    return Err(());
                }
                Some(Symbol::Import(..)) => unreachable!(),
            };
        }

        let mut s = self
            .variable_symbols
            .get(&(import_file_no, contract_no, id.name.to_owned()))
            .or_else(|| {
                self.function_symbols
                    .get(&(import_file_no, contract_no, id.name.to_owned()))
            });

        if contract_no.is_some() {
            // try global scope
            if s.is_none() {
                s = self
                    .variable_symbols
                    .get(&(import_file_no, None, id.name.to_owned()));
            }

            if s.is_none() {
                s = self
                    .function_symbols
                    .get(&(import_file_no, None, id.name.to_owned()));
            }
        }

        Ok(s)
    }

    // An array type can look like foo[2] foo.baz.bar, if foo is an enum type. The
    // lalrpop parses this as an expression, so we need to convert it to Type
    // and check there are no unexpected expressions types.
    #[allow(clippy::vec_init_then_push)]
    pub fn expr_to_type<'a>(
        &mut self,
        file_no: usize,
        contract_no: Option<usize>,
        expr: &'a program::Expression,
        diagnostics: &mut Diagnostics,
    ) -> Result<
        (
            Vec<&'a program::Identifier>,
            program::Expression,
            Vec<ArrayDimension>,
        ),
        (),
    > {
        let mut expr = expr;
        let mut dimensions = vec![];

        loop {
            expr = match expr {
                program::Expression::ArraySubscript(_, r, None) => {
                    dimensions.push(None);

                    r.as_ref()
                }
                program::Expression::ArraySubscript(_, r, Some(index)) => {
                    dimensions.push(self.resolve_array_dimension(
                        file_no,
                        contract_no,
                        None,
                        index,
                        diagnostics,
                    )?);

                    r.as_ref()
                }
                program::Expression::Variable(_) | program::Expression::Type(..) => {
                    return Ok((Vec::new(), expr.clone(), dimensions))
                }
                program::Expression::MemberAccess(_, namespace, id) => {
                    let mut names = Vec::new();

                    let mut expr = namespace.as_ref();

                    while let program::Expression::MemberAccess(_, member, name) = expr {
                        names.insert(0, name);

                        expr = member.as_ref();
                    }

                    if let program::Expression::Variable(namespace) = expr {
                        names.insert(0, namespace);

                        return Ok((names, program::Expression::Variable(id.clone()), dimensions));
                    } else {
                        diagnostics.push(Diagnostic::decl_error(
                            namespace.loc(),
                            "expression found where type expected".to_string(),
                        ));
                        return Err(());
                    }
                }
                _ => {
                    diagnostics.push(Diagnostic::decl_error(
                        expr.loc(),
                        "expression found where type expected".to_string(),
                    ));
                    return Err(());
                }
            }
        }
    }

    /// Resolve an expression which defines the array length, e.g. 2**8 in
    /// "bool[2**8]"
    fn resolve_array_dimension(
        &mut self,
        file_no: usize,
        contract_no: Option<usize>,
        function_no: Option<usize>,
        expr: &program::Expression,
        diagnostics: &mut Diagnostics,
    ) -> Result<ArrayDimension, ()> {
        let mut symtable = Symtable::new();
        let context = ExprContext {
            file_no,
            contract_no,
            function_no,
            constant: true,
            lvalue: false,
        };

        let size_expr = expression(
            expr,
            &context,
            self,
            &mut symtable,
            diagnostics,
            ResolveTo::Type(&Type::Uint(32)),
        )?;

        match size_expr.ty() {
            Type::Uint(_) => {}
            _ => {
                diagnostics.push(Diagnostic::decl_error(
                    expr.loc(),
                    "expression is not a number".to_string(),
                ));
                return Err(());
            }
        }

        match eval_const_number(&size_expr, self) {
            Ok(n) => Ok(Some(n)),
            Err(d) => {
                diagnostics.push(d);

                Err(())
            }
        }
    }

    /// Generate the signature for the given name and parameters. Can be used
    /// for both events and functions
    pub fn signature(&self, name: &str, params: &[Parameter]) -> String {
        format!(
            "{}({})",
            name,
            params
                .iter()
                .map(|p| p.ty.to_signature_string(false, self))
                .collect::<Vec<String>>()
                .join(",")
        )
    }
}
