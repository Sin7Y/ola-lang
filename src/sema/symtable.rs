// SPDX-License-Identifier: Apache-2.0

use indexmap::IndexMap;
use ola_parser::diagnostics::{ErrorType, Level, Note};
use std::collections::{HashMap, HashSet, LinkedList};
use std::str;
use std::sync::Arc;

use super::ast::{Diagnostic, Namespace, Type};
use crate::sema::ast::Expression;
use ola_parser::program;

#[derive(Clone, Debug)]
pub struct Variable {
    pub id: program::Identifier,
    pub ty: Type,
    pub pos: usize,
    pub slice: bool,
    pub assigned: bool,
    pub read: bool,
    pub usage_type: VariableUsage,
    pub initializer: VariableInitializer,
    pub storage_location: Option<program::StorageLocation>,
}

#[derive(Clone, Debug)]
pub enum VariableInitializer {
    Ola(Option<Arc<Expression>>),
}

impl VariableInitializer {
    pub fn has_initializer(&self) -> bool {
        match self {
            VariableInitializer::Ola(expr) => expr.is_some(),
        }
    }
}

impl Variable {
    pub fn is_reference(&self) -> bool {
        // If the variable has the memory or storage keyword, it can be a reference to
        // another variable. In this case, an assigment may change the value of
        // the variable it is referencing.
        if matches!(
            self.storage_location,
            Some(program::StorageLocation::Memory(_)) | Some(program::StorageLocation::Storage(_))
        ) {
            if let VariableInitializer::Ola(Some(expr)) = &self.initializer {
                // If the initializer is an array allocation, a constructor or a struct literal,
                // the variable is not a reference to another.
                return !matches!(
                    **expr,
                    Expression::AllocDynamicBytes { .. }
                        | Expression::ArrayLiteral { .. }
                        | Expression::StructLiteral { .. }
                );
            }
        }

        false
    }
}

#[derive(Clone, Debug)]
pub enum VariableUsage {
    Parameter,
    ReturnVariable,
    AnonymousReturnVariable,
    LocalVariable,
    DestructureVariable,
}

#[derive(Debug, Clone)]
struct VarScope(HashMap<String, usize>, Option<HashSet<usize>>);

#[derive(Default, Debug, Clone)]
pub struct Symtable {
    pub vars: IndexMap<usize, Variable>,
    names: Vec<VarScope>,
    pub arguments: Vec<Option<usize>>,
    pub returns: Vec<usize>,
}

impl Symtable {
    pub fn new() -> Self {
        Symtable {
            vars: IndexMap::new(),
            names: vec![VarScope(HashMap::new(), None)],
            arguments: Vec::new(),
            returns: Vec::new(),
        }
    }

    pub fn add(
        &mut self,
        id: &program::Identifier,
        ty: Type,
        ns: &mut Namespace,
        initializer: VariableInitializer,
        usage_type: VariableUsage,
        storage_location: Option<program::StorageLocation>,
    ) -> Option<usize> {
        let pos = ns.next_id;
        ns.next_id += 1;

        self.vars.insert(
            pos,
            Variable {
                id: id.clone(),
                ty,
                pos,
                slice: false,
                initializer,
                assigned: false,
                usage_type,
                read: false,
                storage_location,
            },
        );

        // the variable has no name, like unnamed return or parameters values
        if !id.name.is_empty() {
            if let Some(prev) = self.find(&id.name) {
                ns.diagnostics.push(Diagnostic::error_with_note(
                    id.loc,
                    format!("{} is already declared", id.name),
                    prev.id.loc,
                    "location of previous declaration".to_string(),
                ));
                return None;
            }

            self.names
                .last_mut()
                .unwrap()
                .0
                .insert(id.name.to_string(), pos);
        }

        Some(pos)
    }

    pub fn exclusive_add(
        &mut self,
        id: &program::Identifier,
        ty: Type,
        ns: &mut Namespace,
        initializer: VariableInitializer,
        usage_type: VariableUsage,
        storage_location: Option<program::StorageLocation>,
    ) -> Option<usize> {
        if let Some(var) = self.find(&id.name) {
            ns.diagnostics.push(Diagnostic {
                level: Level::Error,
                ty: ErrorType::DeclarationError,
                loc: id.loc,
                message: format!("variable name '{}' already used in this scope", id.name),
                notes: vec![Note {
                    loc: var.id.loc,
                    message: "found previous declaration here".to_string(),
                }],
            });
            return None;
        }

        self.add(id, ty, ns, initializer, usage_type, storage_location)
    }

    pub fn find(&self, name: &str) -> Option<&Variable> {
        for scope in &self.names {
            if let Some(n) = scope.0.get(name) {
                return self.vars.get(n);
            }
        }

        None
    }

    pub fn new_scope(&mut self) {
        self.names.push(VarScope(HashMap::new(), None));
    }

    pub fn leave_scope(&mut self) {
        self.names.pop();
    }

    pub fn get_name(&self, pos: usize) -> &str {
        &self.vars[&pos].id.name
    }
}

pub struct LoopScope {
    pub no_breaks: usize,
    pub no_continues: usize,
}

pub struct LoopScopes(Vec<LoopScope>);

impl Default for LoopScopes {
    fn default() -> Self {
        LoopScopes::new()
    }
}

impl LoopScopes {
    pub fn new() -> Self {
        LoopScopes(Vec::new())
    }

    pub fn new_scope(&mut self) {
        self.0.push(LoopScope {
            no_breaks: 0,
            no_continues: 0,
        })
    }

    pub fn leave_scope(&mut self) -> LoopScope {
        self.0.pop().unwrap()
    }

    pub fn do_break(&mut self) -> bool {
        match self.0.last_mut() {
            Some(scope) => {
                scope.no_breaks += 1;
                true
            }
            None => false,
        }
    }

    pub fn do_continue(&mut self) -> bool {
        match self.0.last_mut() {
            Some(scope) => {
                scope.no_continues += 1;
                true
            }
            None => false,
        }
    }
}
