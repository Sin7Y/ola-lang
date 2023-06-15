// SPDX-License-Identifier: Apache-2.0

use super::{
    ast::{
        ArrayLength, Contract, Diagnostic, EnumDecl, Mapping, Namespace, Parameter, StructDecl,
        Symbol, Type, UserTypeDecl,
    },
    diagnostics::Diagnostics,
};
use indexmap::IndexMap;
use itertools::Itertools;
use num_bigint::BigInt;
use num_traits::{One, Zero};
use ola_parser::diagnostics::Note;
use ola_parser::{program, program::CodeLocation};
use petgraph::algo::{all_simple_paths, tarjan_scc};
use petgraph::stable_graph::IndexType;
use petgraph::Directed;
use std::collections::HashSet;
use std::{fmt::Write, ops::Mul};

type Graph = petgraph::Graph<(), usize, Directed, usize>;

/// List the types which should be resolved later
pub struct ResolveFields<'a> {
    structs: Vec<ResolveStructFields<'a>>,
}

struct ResolveStructFields<'a> {
    struct_no: usize,
    pt: &'a program::StructDefinition,
    contract: Option<usize>,
}

/// Resolve all the types we can find (enums, structs, contracts). structs can
/// have other structs as fields, including ones that have not been declared
/// yet.
pub fn resolve_typenames<'a>(
    s: &'a program::SourceUnit,
    file_no: usize,
    ns: &mut Namespace,
) -> ResolveFields<'a> {
    let mut delay = ResolveFields {
        structs: Vec::new(),
    };

    for part in &s.0 {
        if let program::SourceUnitPart::ContractDefinition(def) = part {
            resolve_contract(def, file_no, &mut delay, ns);
        }
    }

    delay
}

fn type_decl(
    def: &program::TypeDefinition,
    file_no: usize,
    contract_no: Option<usize>,
    ns: &mut Namespace,
) {
    let mut diagnostics = Diagnostics::default();

    let mut ty = match ns.resolve_type(file_no, contract_no, &def.ty, &mut diagnostics) {
        Ok(ty) => ty,
        Err(_) => {
            ns.diagnostics.extend(diagnostics);
            return;
        }
    };

    // We could permit all types to be defined here, however:
    // - This would require resolving the types definition after all other types are
    //   resolved
    // - Need for circular checks (type a is b; type b is a;)
    if !matches!(ty, Type::Address | Type::Uint(_) | Type::Bool) {
        ns.diagnostics.push(Diagnostic::error(
            def.ty.loc(),
            format!("'{}' is not an elementary value type", ty.to_string(ns)),
        ));
        ty = Type::Unresolved;
    }

    let pos = ns.user_types.len();

    if !ns.add_symbol(
        file_no,
        contract_no,
        &def.name,
        Symbol::UserType(def.name.loc, pos),
    ) {
        return;
    }

    ns.user_types.push(UserTypeDecl {
        loc: def.loc,
        name: def.name.name.to_string(),
        ty,
        contract: contract_no.map(|no| ns.contracts[no].name.to_string()),
    });
}

/// A struct field is considered to be of infinite size, if it contains itself
/// infinite times (not in a vector).
///
/// This function sets the `infinitie_size` flag accordingly for all connections
/// between `nodes`. `nodes` is assumed to be a set of strongly connected nodes
/// from within the `graph`.
///
/// Any node (struct) can have one or more edges (types) to some other node
/// (struct). A struct field is not of infinite size, if there are any 2
/// connecting nodes, where all edges between the 2 connecting nodes are
/// mappings or dynamic arrays.
///
/// ```solidity
/// struct A { B b; }                           // finite memory size
/// struct B { A[] a; mapping (uint => A) m; }  // finite memory size
///
/// struct C { D d; }                           // infinite memory size
/// struct D { C[] c1; C c2; }                  // infinite memory size
/// ```
fn check_infinite_struct_size(graph: &Graph, nodes: Vec<usize>, ns: &mut Namespace) {
    let mut infinite_size = true;
    let mut offenders = HashSet::new();
    for (a, b) in nodes.windows(2).map(|w| (w[0], w[1])) {
        let mut infinite_edge = false;
        for edge in graph.edges_connecting(a.into(), b.into()) {
            match &ns.structs[a].fields[*edge.weight()].ty {
                Type::Array(_, dims) if dims.first() != Some(&ArrayLength::Dynamic) => {}
                Type::Struct(_) => {}
                _ => continue,
            }
            infinite_edge = true;
            offenders.insert((a, *edge.weight()));
        }
        infinite_size &= infinite_edge;
    }
    if infinite_size {
        for (struct_no, field_no) in offenders {
            ns.structs[struct_no].fields[field_no].infinite_size = true;
        }
    }
}

/// A struct field is recursive, if it is connected to a cyclic path.
///
/// This function checks all structs in the `ns` for any paths leading into the
/// given `node`. `node` is supposed to be inside a cycle.
/// All affected struct fields will be flagged as recursive (and infinite size
/// as well, if they are).
fn check_recursive_struct_field(node: usize, graph: &Graph, ns: &mut Namespace) {
    for n in 0..ns.structs.len() {
        for path in all_simple_paths::<Vec<_>, &Graph>(graph, n.into(), node.into(), 0, None) {
            for (a, b) in path.windows(2).map(|a_b| (a_b[0], a_b[1])) {
                for edge in graph.edges_connecting(a, b) {
                    ns.structs[a.index()].fields[*edge.weight()].recursive = true;
                    if ns.structs[b.index()].fields.iter().any(|f| f.infinite_size) {
                        ns.structs[a.index()].fields[*edge.weight()].infinite_size = true;
                    }
                }
            }
        }
    }
}

/// check if a struct contains itself. This function calls itself recursively
fn find_struct_recursion(ns: &mut Namespace) {
    let mut edges = HashSet::new();
    for n in 0..ns.structs.len() {
        collect_struct_edges(n, &mut edges, ns);
    }
    let graph = Graph::from_edges(edges);
    for n in tarjan_scc(&graph).iter().flatten().dedup() {
        // Don't use None. It'll default to `node_count() - 1` and fail to find path for
        // graphs like this: `A <-> B`
        let max_len = Some(graph.node_count());
        if let Some(cycle) = all_simple_paths::<Vec<_>, &Graph>(&graph, *n, *n, 0, max_len).next() {
            check_infinite_struct_size(&graph, cycle.iter().map(|p| p.index()).collect(), ns);
            check_recursive_struct_field(n.index(), &graph, ns);
        }
    }
    for n in 0..ns.structs.len() {
        let mut notes = vec![];
        for field in ns.structs[n].fields.iter().filter(|f| f.infinite_size) {
            let loc = field.loc;
            let message = format!("recursive field '{}'", field.name_as_str());
            notes.push(Note { loc, message });
        }
        if !notes.is_empty() {
            ns.diagnostics.push(Diagnostic::error_with_notes(
                ns.structs[n].loc,
                format!("struct '{}' has infinite size", ns.structs[n].name),
                notes,
            ));
        }
    }
}

pub fn resolve_fields(delay: ResolveFields, file_no: usize, ns: &mut Namespace) {
    // now we can resolve the fields for the structs
    for resolve in delay.structs {
        let fields = struct_decl(resolve.pt, file_no, resolve.contract, ns);

        ns.structs[resolve.struct_no].fields = fields;
    }

    // Handle recursive struct fields.
    find_struct_recursion(ns);

    // Calculate the offset of each field in all the struct types
    struct_offsets(ns);
}

/// Resolve all the types in a contract
fn resolve_contract<'a>(
    def: &'a program::ContractDefinition,
    file_no: usize,
    delay: &mut ResolveFields<'a>,
    ns: &mut Namespace,
) -> bool {
    let contract_no = ns.contracts.len();

    let name = def.name.as_ref().unwrap();
    ns.contracts.push(Contract::new(&name.name, def.loc));

    let mut broken = !ns.add_symbol(
        file_no,
        None,
        def.name.as_ref().unwrap(),
        Symbol::Contract(def.loc, contract_no),
    );

    if is_windows_reserved(&def.name.as_ref().unwrap().name) {
        ns.diagnostics.push(Diagnostic::error(
            def.name.as_ref().unwrap().loc,
            format!(
                "contract name '{}' is reserved file name on Windows",
                def.name.as_ref().unwrap().name
            ),
        ));
    }

    for parts in &def.parts {
        match parts {
            program::ContractPart::EnumDefinition(ref e) => {
                if !enum_decl(e, file_no, Some(contract_no), ns) {
                    broken = true;
                }
            }
            program::ContractPart::StructDefinition(ref pt) => {
                let struct_no = ns.structs.len();

                if ns.add_symbol(
                    file_no,
                    Some(contract_no),
                    pt.name.as_ref().unwrap(),
                    Symbol::Struct(pt.name.as_ref().unwrap().loc, struct_no),
                ) {
                    ns.structs.push(StructDecl {
                        name: pt.name.as_ref().unwrap().name.to_owned(),
                        loc: pt.name.as_ref().unwrap().loc,
                        contract: Some(def.name.as_ref().unwrap().name.to_owned()),
                        fields: Vec::new(),
                        offsets: Vec::new(),
                        storage_offsets: Vec::new(),
                    });

                    delay.structs.push(ResolveStructFields {
                        struct_no,
                        pt,
                        contract: Some(contract_no),
                    });
                } else {
                    broken = true;
                }
            }
            program::ContractPart::TypeDefinition(ty) => {
                type_decl(ty, file_no, Some(contract_no), ns);
            }
            _ => (),
        }
    }

    broken
}

/// Resolve a parsed struct definition. The return value will be true if the
/// entire definition is valid; however, whatever could be parsed will be added
/// to the resolved contract, so that we can continue producing compiler
/// messages for the remainder of the contract, even if the struct contains an
/// invalid definition.
pub fn struct_decl(
    def: &program::StructDefinition,
    file_no: usize,
    contract_no: Option<usize>,
    ns: &mut Namespace,
) -> Vec<Parameter> {
    let mut fields: Vec<Parameter> = Vec::new();

    for field in &def.fields {
        let mut diagnostics = Diagnostics::default();

        let ty = match ns.resolve_type(file_no, contract_no, &field.ty, &mut diagnostics) {
            Ok(s) => s,
            Err(()) => {
                ns.diagnostics.extend(diagnostics);
                Type::Unresolved
            }
        };

        if let Some(other) = fields.iter().find(|f| {
            f.id.as_ref().map(|id| id.name.as_str())
                == Some(field.name.as_ref().unwrap().name.as_str())
        }) {
            ns.diagnostics.push(Diagnostic::error_with_note(
                field.name.as_ref().unwrap().loc,
                format!(
                    "struct '{}' has duplicate struct field '{}'",
                    def.name.as_ref().unwrap().name,
                    field.name.as_ref().unwrap().name
                ),
                other.loc,
                format!(
                    "location of previous declaration of '{}'",
                    other.name_as_str()
                ),
            ));
            continue;
        }
        if let Some(storage) = &field.storage {
            ns.diagnostics.push(Diagnostic::error(
                storage.loc(),
                format!("storage location '{storage}' not allowed for struct field"),
            ));
        }

        fields.push(Parameter {
            loc: field.loc,
            id: Some(program::Identifier {
                name: field.name.as_ref().unwrap().name.to_string(),
                loc: field.name.as_ref().unwrap().loc,
            }),
            ty,
            ty_loc: Some(field.ty.loc()),
            infinite_size: false,
            recursive: false,
        });
    }

    if fields.is_empty() {
        ns.diagnostics.push(Diagnostic::error(
            def.name.as_ref().unwrap().loc,
            format!(
                "struct definition for '{}' has no fields",
                def.name.as_ref().unwrap().name
            ),
        ));
    }

    fields
}

/// Find all other structs a given user struct may reach.
///
/// `edges` is a set with tuples of 3 dimensions. The first two are the
/// connecting nodes (struct numbers). The last dimension is the field number of
/// the first struct where the connection originates.
fn collect_struct_edges(no: usize, edges: &mut HashSet<(usize, usize, usize)>, ns: &Namespace) {
    for (field_no, field) in ns.structs[no].fields.iter().enumerate() {
        for reaching in field.ty.user_struct_no(ns) {
            if edges.insert((no, reaching, field_no)) {
                collect_struct_edges(reaching, edges, ns)
            }
        }
    }
}

/// Parse enum declaration. If the declaration is invalid, it is still generated
/// so that we can continue parsing, with errors recorded.
fn enum_decl(
    enum_: &program::EnumDefinition,
    file_no: usize,
    contract_no: Option<usize>,
    ns: &mut Namespace,
) -> bool {
    let mut valid = true;

    if enum_.values.is_empty() {
        ns.diagnostics.push(Diagnostic::error(
            enum_.name.as_ref().unwrap().loc,
            format!("enum '{}' has no fields", enum_.name.as_ref().unwrap().name),
        ));
        valid = false;
    } else if enum_.values.len() > 256 {
        ns.diagnostics.push(Diagnostic::error(
            enum_.name.as_ref().unwrap().loc,
            format!(
                "enum '{}' has {} fields, which is more than the 256 limit",
                enum_.name.as_ref().unwrap().name,
                enum_.values.len()
            ),
        ));
        valid = false;
    }

    // check for duplicates
    let mut entries: IndexMap<String, program::Loc> = IndexMap::new();

    for e in enum_.values.iter() {
        if let Some(prev) = entries.get(&e.as_ref().unwrap().name.to_string()) {
            ns.diagnostics.push(Diagnostic::error_with_note(
                e.as_ref().unwrap().loc,
                format!("duplicate enum value {}", e.as_ref().unwrap().name),
                *prev,
                "location of previous definition".to_string(),
            ));
            valid = false;
            continue;
        }

        entries.insert(
            e.as_ref().unwrap().name.to_string(),
            e.as_ref().unwrap().loc,
        );
    }

    let decl = EnumDecl {
        name: enum_.name.as_ref().unwrap().name.to_string(),
        loc: enum_.loc,
        contract: match contract_no {
            Some(c) => Some(ns.contracts[c].name.to_owned()),
            None => None,
        },
        // TODO change type to field ?
        ty: Type::Uint(32),
        values: entries,
    };

    let pos = ns.enums.len();

    ns.enums.push(decl);

    if !ns.add_symbol(
        file_no,
        contract_no,
        enum_.name.as_ref().unwrap(),
        Symbol::Enum(enum_.name.as_ref().unwrap().loc, pos),
    ) {
        valid = false;
    }

    valid
}

/// Calculate the offsets for the fields in structs, and also the size of a
/// struct overall.
///
/// Structs can be recursive, and we may not know the size of a field if the
/// field is a struct and we have not calculated yet. In this case we will get
/// size 0. So, loop over all the structs until all the offsets are unchanged.
fn struct_offsets(ns: &mut Namespace) {
    loop {
        let mut changes = false;
        for struct_no in 0..ns.structs.len() {
            // first in-memory
            let mut offsets = Vec::new();
            let mut offset = BigInt::zero();
            let mut largest_alignment = 0;

            for field in &ns.structs[struct_no].fields {
                let alignment = field.ty.align_of(ns);
                largest_alignment = std::cmp::max(alignment, largest_alignment);
                let remainder = offset.clone() % alignment;

                if remainder > BigInt::zero() {
                    offset += alignment - remainder;
                }

                offsets.push(offset.clone());

                if !field.recursive {
                    offset += field.ty.storage_size(ns);
                }
            }

            // add entry for overall size
            if largest_alignment > 1 {
                let remainder = offset.clone() % largest_alignment;

                if remainder > BigInt::zero() {
                    offset += largest_alignment - remainder;
                }
            }

            offsets.push(offset);

            if ns.structs[struct_no].offsets != offsets {
                ns.structs[struct_no].offsets = offsets;
                changes = true;
            }

            let mut storage_offsets = Vec::new();
            let mut offset = BigInt::zero();
            let mut largest_alignment = BigInt::zero();

            for field in &ns.structs[struct_no].fields {
                if !field.infinite_size {
                    let alignment = BigInt::from(1);
                    largest_alignment = std::cmp::max(alignment.clone(), largest_alignment.clone());
                    let remainder = offset.clone() % alignment.clone();

                    if remainder > BigInt::zero() {
                        offset += alignment - remainder;
                    }
                    storage_offsets.push(offset.clone());

                    offset += field.ty.storage_slots(ns);
                }
            }

            // add entry for overall size
            if largest_alignment > BigInt::one() {
                let remainder = offset.clone() % largest_alignment.clone();

                if remainder > BigInt::zero() {
                    offset += largest_alignment - remainder;
                }
            }
            storage_offsets.push(offset);

            if ns.structs[struct_no].storage_offsets != storage_offsets {
                ns.structs[struct_no].storage_offsets = storage_offsets;
                changes = true;
            }
        }

        if !changes {
            break;
        }
    }
}

impl Type {
    /// Return the set of user defined structs this type encapsulates.
    pub fn user_struct_no(&self, ns: &Namespace) -> HashSet<usize> {
        match self {
            Type::Struct(n) => HashSet::from([*n]),
            Type::Mapping(Mapping { key, value, .. }) => {
                let mut result = key.user_struct_no(ns);
                result.extend(value.user_struct_no(ns));
                result
            }
            // TODO add mapping
            Type::Array(ty, _) | Type::Ref(ty) | Type::Slice(ty) | Type::StorageRef(ty) => {
                ty.user_struct_no(ns)
            }
            Type::UserType(no) => ns.user_types[*no].ty.user_struct_no(ns),
            _ => HashSet::new(),
        }
    }
    pub fn to_string(&self, ns: &Namespace) -> String {
        match self {
            Type::Bool => "bool".to_string(),
            Type::Address => "address".to_string(),
            Type::Uint(n) => format!("u{}", n),
            Type::String => "string".to_string(),
            Type::Enum(n) => format!("enum {}", ns.enums[*n]),
            Type::Struct(n) => format!("struct {}", ns.structs[*n]),
            Type::Array(ty, len) => format!(
                "{}{}",
                ty.to_string(ns),
                len.iter()
                    .map(|len| match len {
                        ArrayLength::Fixed(len) => format!("[{}]", len),
                        _ => "[]".to_string(),
                    })
                    .collect::<String>()
            ),
            Type::Mapping(Mapping {
                key,
                key_name,
                value,
                value_name,
            }) => {
                format!(
                    "mapping({}{}{} => {}{}{})",
                    key.to_string(ns),
                    if key_name.is_some() { " " } else { "" },
                    key_name.as_ref().map(|id| id.name.as_str()).unwrap_or(""),
                    value.to_string(ns),
                    if value_name.is_some() { " " } else { "" },
                    value_name.as_ref().map(|id| id.name.as_str()).unwrap_or(""),
                )
            }
            Type::Function { params, returns } => {
                let mut s = format!(
                    "fn({}) ",
                    params
                        .iter()
                        .map(|ty| ty.to_string(ns))
                        .collect::<Vec<String>>()
                        .join(","),
                );

                if !returns.is_empty() {
                    write!(
                        s,
                        " returns ({})",
                        returns
                            .iter()
                            .map(|ty| ty.to_string(ns))
                            .collect::<Vec<String>>()
                            .join(",")
                    )
                    .unwrap();
                }

                s
            }
            Type::Contract(n) => format!("contract {}", ns.contracts[*n].name),
            Type::UserType(n) => format!("usertype {}", ns.user_types[*n]),
            Type::Ref(r) => r.to_string(ns),
            Type::StorageRef(ty) => format!("{} storage", ty.to_string(ns)),
            Type::Void => "void".to_owned(),
            Type::Unreachable => "unreachable".into(),
            Type::Slice(ty) => format!("{} slice", ty.to_string(ns)),
            Type::Unresolved => "unresolved".to_owned(),
            Type::BufferPointer => "buffer_pointer".to_owned(),
        }
    }

    /// Is this a primitive, i.e. bool, address, int, uint, bytes
    pub fn is_primitive(&self) -> bool {
        match self {
            Type::Bool => true,
            Type::Address => true,
            Type::Uint(_) => true,
            Type::Ref(r) => r.is_primitive(),
            Type::StorageRef(r) => r.is_primitive(),
            _ => false,
        }
    }

    /// The eth abi file wants to hear "tuple" rather than "(ty, ty)"
    pub fn to_signature_string(&self, say_tuple: bool, ns: &Namespace) -> String {
        match self {
            Type::Bool => "bool".to_string(),
            Type::Contract(_) | Type::Address => "address".to_string(),
            Type::Uint(n) => format!("u{}", n),
            Type::String => "string".to_string(),
            Type::Enum(n) => ns.enums[*n].ty.to_signature_string(say_tuple, ns),
            Type::Array(ty, len) => format!(
                "{}{}",
                ty.to_signature_string(say_tuple, ns),
                len.iter()
                    .map(|len| match len {
                        ArrayLength::Fixed(len) => format!("[{}]", len),
                        _ => "[]".to_string(),
                    })
                    .collect::<String>()
            ),
            Type::Ref(r) => r.to_string(ns),
            Type::StorageRef(r) => r.to_string(ns),
            Type::Struct(_) if say_tuple => "tuple".to_string(),
            Type::Struct(n) => {
                format!(
                    "({})",
                    ns.structs[*n]
                        .fields
                        .iter()
                        .map(|f| f.ty.to_signature_string(say_tuple, ns))
                        .collect::<Vec<String>>()
                        .join(",")
                )
            }
            Type::Function { .. } => "fn".to_owned(),
            Type::UserType(n) => ns.user_types[*n].ty.to_signature_string(say_tuple, ns),
            // TODO: should an unresolved type not match another unresolved type?
            Type::Unresolved => "unresolved".to_owned(),
            Type::Slice(ty) => format!("{} slice", ty.to_string(ns)),
            _ => unreachable!(),
        }
    }

    /// Fetch the type of an array element
    pub fn elem_ty(&self) -> Self {
        match self {
            Type::Array(ty, _) => *ty.clone(),
            _ => unreachable!("Type is not an array"),
        }
    }

    /// Is this a reference type of fixed size
    pub fn is_fixed_reference_type(&self) -> bool {
        match self {
            Type::Bool => false,
            Type::Address => false,
            Type::Uint(_) => false,
            Type::Enum(_) => false,
            Type::Struct(_) => true,
            Type::Array(_, dims) => !dims.iter().any(|d| *d == ArrayLength::Dynamic),
            Type::Contract(_) => false,
            Type::String => false,
            Type::Mapping(..) => false,
            Type::Slice(_) => false,
            Type::Unresolved => false,
            Type::Ref(_) => false,
            Type::Function { .. } => false,
            Type::StorageRef(..) => false,
            _ => unreachable!("{:?}", self),
        }
    }

    /// Given an array, return the type of its elements
    #[must_use]
    pub fn array_elem(&self) -> Self {
        match self {
            Type::Array(ty, dim) if dim.len() > 1 => {
                Type::Array(ty.clone(), dim[..dim.len() - 1].to_vec())
            }
            Type::Array(ty, dim) if dim.len() == 1 => *ty.clone(),
            _ => panic!("not an array"),
        }
    }

    /// Give the type of an storage array after dereference. This can only be
    /// used on array types and will cause a panic otherwise.
    #[must_use]
    pub fn storage_array_elem(&self) -> Self {
        match self {
            Type::Mapping(Mapping { value, .. }) => Type::StorageRef(value.clone()),
            Type::Array(ty, dim) if dim.len() > 1 => Type::StorageRef(Box::new(Type::Array(
                ty.clone(),
                dim[..dim.len() - 1].to_vec(),
            ))),
            Type::Array(ty, dim) if dim.len() == 1 => Type::StorageRef(ty.clone()),
            Type::StorageRef(ty) => ty.storage_array_elem(),
            _ => panic!("deref on non-array"),
        }
    }

    /// Give the length of the outer array. This can only be called on array
    /// types and will panic otherwise.
    pub fn array_length(&self) -> Option<&BigInt> {
        match self {
            Type::StorageRef(ty) => ty.array_length(),
            Type::Ref(ty) => ty.array_length(),
            Type::Array(_, dim) => dim.last().unwrap().array_length(),
            _ => panic!("array_length on non-array"),
        }
    }

    /// Returns the size a type occupies in memory
    pub fn memory_size_of(&self, ns: &Namespace) -> BigInt {
        self.memory_size_of_internal(ns, &mut HashSet::new())
    }

    pub fn memory_size_of_internal(
        &self,
        ns: &Namespace,
        structs_visited: &mut HashSet<usize>,
    ) -> BigInt {
        self.guarded_recursion(structs_visited, 0.into(), |structs_visited| match self {
            Type::Enum(_) => BigInt::one(),
            Type::Bool => BigInt::one(),
            Type::Contract(_) | Type::Address => BigInt::from(32),
            Type::Uint(n) => BigInt::from(n / 8),
            Type::Array(_, dims) if dims.first() == Some(&ArrayLength::Dynamic) => BigInt::from(8),
            Type::Array(ty, dims) => {
                let pointer_size = (BigInt::from(8)).into();
                ty.memory_size_of_internal(ns, structs_visited).mul(
                    dims.iter()
                        .map(|d| match d {
                            ArrayLength::Fixed(n) => n,
                            ArrayLength::Dynamic => &pointer_size,
                            ArrayLength::AnyFixed => unreachable!(),
                        })
                        .product::<BigInt>(),
                )
            }
            Type::Struct(n) => ns.structs[*n]
                .fields
                .iter()
                .map(|d| d.ty.memory_size_of_internal(ns, structs_visited))
                .sum::<BigInt>(),
            Type::String | Type::Ref(_) | Type::Slice(_) | Type::StorageRef(..) => BigInt::from(8),
            Type::Unresolved => BigInt::zero(),
            Type::UserType(no) => ns.user_types[*no]
                .ty
                .memory_size_of_internal(ns, structs_visited),
            _ => unimplemented!("sizeof on {:?}", self),
        })
    }

    /// Retrieve the alignment for each type, if it is a struct member.
    /// Arrays are always reference types when declared as local variables.
    /// Inside structs, however, they are the object itself, if they are of
    /// fixed length.
    pub fn struct_elem_alignment(&self, ns: &Namespace) -> BigInt {
        match self {
            Type::Bool
            // Contract and address are arrays of u8, so they align with one.
            | Type::Contract(_)
            | Type::Address
            | Type::Enum(_) => BigInt::one(),

            Type::Uint(n) => BigInt::from(n / 8),
            Type::Array(ty, dims) => {
                if dims.iter().any(|d| *d == ArrayLength::Dynamic) {
                    BigInt::from(8)
                } else {
                    ty.struct_elem_alignment(ns)
                }
            }

            Type::Struct(n) => {
                ns.structs[*n].fields.iter().map(|d| d.ty.struct_elem_alignment(ns)).max().unwrap()
            }
            Type::String
            | Type::Ref(_)
            | Type::StorageRef(..) => BigInt::from(8),
            Type::UserType(no) => ns.user_types[*no].ty.struct_elem_alignment(ns),

            _ => unreachable!("Type should not appear on a struct"),

        }
    }

    /// Calculate how much memory this type occupies in Solana's storage.
    /// Depending on the llvm implementation there might be padding between
    /// elements which is not accounted for.
    pub fn storage_size(&self, ns: &Namespace) -> BigInt {
        match self {
            Type::Array(ty, dims) => {
                let pointer_size = BigInt::from(4);
                ty.storage_size(ns).mul(
                    dims.iter()
                        .map(|d| match d {
                            ArrayLength::Dynamic => &pointer_size,
                            ArrayLength::Fixed(d) => d,
                            ArrayLength::AnyFixed => panic!("unknown length"),
                        })
                        .product::<BigInt>(),
                )
            }
            Type::Struct(n) => ns.structs[*n]
                .offsets
                .last()
                .cloned()
                .unwrap_or_else(BigInt::zero),
            Type::String => BigInt::from(4),
            Type::Ref(ty) | Type::StorageRef(ty) => ty.storage_size(ns),
            Type::UserType(no) => ns.user_types[*no].ty.storage_size(ns),
            // Other types have the same size both in storage and in memory
            _ => self.memory_size_of(ns),
        }
    }

    /// Does this type fit into memory
    pub fn fits_in_memory(&self, ns: &Namespace) -> bool {
        self.memory_size_of(ns) < BigInt::from(u16::MAX)
    }

    /// Calculate the alignment
    pub fn align_of(&self, ns: &Namespace) -> usize {
        match self {
            Type::Uint(n) => (*n / 32).into(),
            Type::Struct(n) => ns.structs[*n]
                .fields
                .iter()
                .map(|f| if f.recursive { 1 } else { f.ty.align_of(ns) })
                .max()
                .unwrap(),
            _ => 1,
        }
    }

    pub fn bits(&self, ns: &Namespace) -> u16 {
        match self {
            Type::Address | Type::Contract(_) => 256 as u16,
            Type::Bool => 1,
            Type::Uint(n) => *n,
            Type::Ref(ty) => ty.bits(ns),
            Type::StorageRef(..) => Type::Uint(32).bits(ns),
            Type::Enum(n) => ns.enums[*n].ty.bits(ns),
            _ => panic!("type not allowed"),
        }
    }

    pub fn is_integer(&self, ns: &Namespace) -> bool {
        match self {
            Type::Uint(_) => true,
            Type::Ref(r) => r.is_integer(ns),
            Type::StorageRef(r) => r.is_integer(ns),
            Type::UserType(user) => ns.user_types[*user].ty.is_integer(ns),
            _ => false,
        }
    }

    /// Calculate how many storage slots a type occupies. Note that storage
    /// arrays can be very large
    pub fn storage_slots(&self, ns: &Namespace) -> BigInt {
        match self {
            Type::StorageRef(r) | Type::Ref(r) => r.storage_slots(ns),
            Type::Struct(no) => ns.structs[*no]
                .fields
                .iter()
                .filter(|f| !f.infinite_size)
                .map(|f| f.ty.storage_slots(ns))
                .sum(),
            Type::Array(_, dims) if dims.first() == Some(&ArrayLength::Dynamic) => 1.into(),
            Type::Array(ty, dims) => {
                let one = 1.into();
                ty.storage_slots(ns)
                    * dims
                        .iter()
                        .map(|len| match len {
                            ArrayLength::Dynamic => &one,
                            ArrayLength::Fixed(len) => len,
                            ArrayLength::AnyFixed => {
                                unreachable!("unknown length")
                            }
                        })
                        .product::<BigInt>()
            }
            _ => BigInt::one(),
        }
    }

    /// Give the type of an memory array after dereference
    #[must_use]
    pub fn array_deref(&self) -> Self {
        match self {
            Type::String => Type::Ref(Box::new(Type::Uint(32))),
            Type::Ref(t) => t.array_deref(),
            Type::Array(ty, dim) if dim.len() > 1 => Type::Ref(Box::new(Type::Array(
                ty.clone(),
                dim[..dim.len() - 1].to_vec(),
            ))),
            Type::Array(ty, dim) if dim.len() == 1 => Type::Ref(ty.clone()),
            Type::Slice(ty) => Type::Ref(Box::new(*ty.clone())),
            _ => panic!("deref on non-array"),
        }
    }

    pub fn is_reference_type(&self, ns: &Namespace) -> bool {
        match self {
            Type::Bool => false,
            Type::Address => false,
            Type::Uint(_) => false,
            Type::Enum(_) => false,
            Type::Struct(_) => true,
            Type::Array(..) => true,
            Type::String => true,
            Type::Mapping(..) => true,
            Type::Contract(_) => false,
            Type::Ref(r) => r.is_reference_type(ns),
            Type::StorageRef(r) => r.is_reference_type(ns),
            Type::Function { .. } => false,
            Type::UserType(no) => ns.user_types[*no].ty.is_reference_type(ns),
            _ => false,
        }
    }

    /// Does this type contain any types which are variable-length
    pub fn is_dynamic(&self, ns: &Namespace) -> bool {
        self.is_dynamic_internal(ns, &mut HashSet::new())
    }

    fn is_dynamic_internal(&self, ns: &Namespace, structs_visited: &mut HashSet<usize>) -> bool {
        self.guarded_recursion(structs_visited, false, |structs_visited| match self {
            Type::String => true,
            Type::Ref(r) => r.is_dynamic_internal(ns, structs_visited),
            Type::Array(ty, dim) => {
                if dim.iter().any(|d| d == &ArrayLength::Dynamic) {
                    return true;
                }
                ty.is_dynamic_internal(ns, structs_visited)
            }
            Type::Struct(n) => ns.structs[*n]
                .fields
                .iter()
                .any(|f| f.ty.is_dynamic_internal(ns, structs_visited)),
            Type::StorageRef(r) => r.is_dynamic_internal(ns, structs_visited),
            Type::Slice(_) => true,
            _ => false,
        })
    }

    /// Can this type have a calldata, memory, or storage location. This is to
    /// be compatible with ethereum solidity. Opinions on whether other
    /// types should be allowed be storage are welcome.
    pub fn can_have_data_location(&self) -> bool {
        matches!(
            self,
            Type::Array(..) | Type::Struct(_) | Type::Mapping(..) | Type::String
        )
    }

    /// Is this a reference to contract storage?
    pub fn is_contract_storage(&self) -> bool {
        matches!(self, Type::StorageRef(..))
    }

    /// Is this a reference to dynamic memory (arrays, strings)
    pub fn is_dynamic_memory(&self) -> bool {
        match self {
            Type::String | Type::Slice(_) => true,
            Type::Array(_, dim) if dim.last() == Some(&ArrayLength::Dynamic) => true,
            Type::Ref(ty) => ty.is_dynamic_memory(),
            _ => false,
        }
    }

    /// Is this a mapping
    pub fn is_mapping(&self) -> bool {
        match self {
            Type::Mapping(..) => true,
            Type::StorageRef(ty) => ty.is_mapping(),
            _ => false,
        }
    }

    /// Is it an address (with some sugar)
    pub fn is_address(&self) -> bool {
        matches!(self, Type::Address | Type::Contract(_))
    }

    /// Does the type contain any mapping type
    pub fn contains_mapping(&self, ns: &Namespace) -> bool {
        self.contains_mapping_internal(ns, &mut HashSet::new())
    }

    fn contains_mapping_internal(
        &self,
        ns: &Namespace,
        structs_visited: &mut HashSet<usize>,
    ) -> bool {
        self.guarded_recursion(structs_visited, false, |structs_visited| match self {
            Type::Mapping(..) => true,
            Type::Array(ty, _) => ty.contains_mapping_internal(ns, structs_visited),
            Type::Struct(no) => ns.structs[*no]
                .fields
                .iter()
                .any(|f| f.ty.contains_mapping_internal(ns, structs_visited)),
            Type::StorageRef(r) | Type::Ref(r) => r.contains_mapping_internal(ns, structs_visited),
            _ => false,
        })
    }

    /// If the type is Ref or StorageRef, get the underlying type
    pub fn deref_any(&self) -> &Self {
        match self {
            Type::StorageRef(r) => r,
            Type::Ref(r) => r,
            _ => self,
        }
    }

    /// If the type is Ref or StorageRef, get the underlying type
    #[must_use]
    pub fn deref_into(self) -> Self {
        match self {
            Type::StorageRef(r) => *r,
            Type::Ref(r) => *r,
            _ => self,
        }
    }

    /// If the type is Ref, get the underlying type
    pub fn deref_memory(&self) -> &Self {
        match self {
            Type::Ref(r) => r,
            _ => self,
        }
    }

    pub fn is_recursive(&self, ns: &Namespace) -> bool {
        match self {
            Type::Struct(n) => ns.structs[*n].fields.iter().any(|f| f.recursive),
            Type::Mapping(Mapping { key, value, .. }) => {
                key.is_recursive(ns) || value.is_recursive(ns)
            }
            Type::Array(ty, _) | Type::Ref(ty) | Type::Slice(ty) | Type::StorageRef(ty) => {
                ty.is_recursive(ns)
            }
            Type::UserType(no) => ns.user_types[*no].ty.is_recursive(ns),
            _ => false,
        }
    }

    fn guarded_recursion<F, O>(&self, structs_visited: &mut HashSet<usize>, bail: O, f: F) -> O
    where
        F: FnOnce(&mut HashSet<usize>) -> O,
    {
        if let Type::Struct(n) = self {
            if !structs_visited.insert(*n) {
                return bail;
            }
        }
        f(structs_visited)
    }
}

/// These names cannot be used on Windows, even with an extension.
/// shamelessly stolen from cargo
fn is_windows_reserved(name: &str) -> bool {
    [
        "con", "prn", "aux", "nul", "com1", "com2", "com3", "com4", "com5", "com6", "com7", "com8",
        "com9", "lpt1", "lpt2", "lpt3", "lpt4", "lpt5", "lpt6", "lpt7", "lpt8", "lpt9",
    ]
    .contains(&name.to_ascii_lowercase().as_str())
}
