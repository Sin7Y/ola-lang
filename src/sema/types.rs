// SPDX-License-Identifier: Apache-2.0

use super::{
    ast::{
        ArrayLength, Contract, Diagnostic, EnumDecl, Namespace, Parameter, StructDecl, Symbol,
        Type, UserTypeDecl,
    },
    diagnostics::Diagnostics,
};
use indexmap::IndexMap;
use num_bigint::BigInt;
use num_traits::{One, Zero};
use ola_parser::{program, program::CodeLocation};
use std::collections::HashSet;
use std::{fmt::Write, ops::Mul};

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
    if !matches!(ty, Type::Uint(_) | Type::Bool) {
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

/// check if a struct contains itself. This function calls itself recursively
fn find_struct_recursion(struct_no: usize, structs_visited: &mut Vec<usize>, ns: &mut Namespace) {
    let def = ns.structs[struct_no].clone();
    let mut types_seen: HashSet<usize> = HashSet::new();

    for (field_no, field) in def.fields.iter().enumerate() {
        if let Type::Struct(field_struct_no) = field.ty {
            if types_seen.contains(&field_struct_no) {
                continue;
            }

            types_seen.insert(field_struct_no);

            if structs_visited.contains(&field_struct_no) {
                ns.diagnostics.push(Diagnostic::error_with_note(
                    def.loc,
                    format!("struct '{}' has infinite size", def.name),
                    field.loc,
                    format!("recursive field '{}'", field.name_as_str()),
                ));

                ns.structs[struct_no].fields[field_no].recursive = true;
            } else {
                structs_visited.push(field_struct_no);
                find_struct_recursion(field_struct_no, structs_visited, ns);
                structs_visited.pop();
            }
        }
    }
}

pub fn resolve_fields(delay: ResolveFields, file_no: usize, ns: &mut Namespace) {
    // now we can resolve the fields for the structs
    for resolve in delay.structs {
        let fields = struct_decl(resolve.pt, file_no, resolve.contract, ns);

        ns.structs[resolve.struct_no].fields = fields;
    }

    // struct can contain other structs, and we have to check for recursiveness,
    // i.e. "struct a { b f1; } struct b { a f1; }"
    (0..ns.structs.len())
        .for_each(|struct_no| find_struct_recursion(struct_no, &mut vec![struct_no], ns));

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

        fields.push(Parameter {
            loc: field.loc,
            id: Some(program::Identifier {
                name: field.name.as_ref().unwrap().name.to_string(),
                loc: field.name.as_ref().unwrap().loc,
            }),
            ty,
            ty_loc: Some(field.ty.loc()),
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

            let mut offset = BigInt::zero();
            let mut largest_alignment = BigInt::zero();

            for field in &ns.structs[struct_no].fields {
                if !field.recursive {
                    let alignment = field.ty.storage_align(ns);
                    largest_alignment = std::cmp::max(alignment.clone(), largest_alignment.clone());
                    let remainder = offset.clone() % alignment.clone();

                    if remainder > BigInt::zero() {
                        offset += alignment - remainder;
                    }

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
        }

        if !changes {
            break;
        }
    }
}

impl Type {
    pub fn to_string(&self, ns: &Namespace) -> String {
        match self {
            Type::Bool => "bool".to_string(),
            Type::Uint(n) => format!("u{}", n),
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
            Type::Uint(_) => true,
            Type::StorageRef(r) => r.is_primitive(),
            _ => false,
        }
    }

    /// The eth abi file wants to hear "tuple" rather than "(ty, ty)"
    pub fn to_signature_string(&self, say_tuple: bool, ns: &Namespace) -> String {
        match self {
            Type::Bool => "bool".to_string(),
            Type::Contract(_) => "address".to_string(),
            Type::Uint(n) => format!("u{}", n),
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
            Type::Uint(_) => false,
            Type::Enum(_) => false,
            Type::Struct(_) => true,
            Type::Array(_, dims) => matches!(dims.last(), Some(ArrayLength::Fixed(_))),
            Type::Contract(_) => false,
            Type::Slice(_) => false,
            Type::Unresolved => false,
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
            Type::Array(_, dim) => dim.last().unwrap().array_length(),
            _ => panic!("array_length on non-array"),
        }
    }

    /// Returns the size a type occupies in memory
    pub fn memory_size_of(&self, ns: &Namespace) -> BigInt {
        match self {
            Type::Enum(_) => BigInt::one(),
            Type::Bool => BigInt::one(),
            Type::Contract(_) => BigInt::from(ns.address_length),
            Type::Uint(n) => BigInt::from(n / 8),
            Type::Array(ty, dims) => {
                let pointer_size = BigInt::one();
                ty.memory_size_of(ns).mul(
                    dims.iter()
                        .map(|d| match d {
                            ArrayLength::Dynamic => &pointer_size,
                            ArrayLength::Fixed(n) => n,
                            ArrayLength::AnyFixed => unreachable!(),
                        })
                        .product::<BigInt>(),
                )
            }
            Type::Struct(n) => ns.structs[*n]
                .fields
                .iter()
                .map(|d| d.ty.memory_size_of(ns))
                .sum::<BigInt>(),
            Type::StorageRef(..) => BigInt::from(4),
            Type::Unresolved => BigInt::zero(),
            Type::UserType(no) => ns.user_types[*no].ty.memory_size_of(ns),
            _ => unimplemented!("sizeof on {:?}", self),
        }
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
            | Type::Enum(_) => BigInt::one(),

            Type::Array(ty, dims) => {
                if dims.iter().any(|d| *d == ArrayLength::Dynamic) {
                    BigInt::one()
                } else {
                    ty.struct_elem_alignment(ns)
                }
            }

            Type::Struct(n) => {
                ns.structs[*n].fields.iter().map(|d| d.ty.struct_elem_alignment(ns)).max().unwrap()
            }
            Type::StorageRef(..) => BigInt::from(4),
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
            Type::StorageRef(ty) => ty.storage_size(ns),
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
            Type::Uint(32) => 1,
            Type::Uint(256) => 8,
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
            Type::Contract(_) => ns.address_length as u16 * 8,
            Type::Bool => 1,
            Type::Uint(n) => *n,
            Type::StorageRef(..) => Type::Uint(32).bits(ns),
            Type::Enum(n) => ns.enums[*n].ty.bits(ns),
            _ => panic!("type not allowed"),
        }
    }

    pub fn is_integer(&self) -> bool {
        match self {
            Type::Uint(_) => true,
            Type::StorageRef(r) => r.is_integer(),
            _ => false,
        }
    }

    /// Calculate how many storage slots a type occupies. Note that storage
    /// arrays can be very large
    pub fn storage_slots(&self, ns: &Namespace) -> BigInt {
        match self {
            Type::Enum(_) => BigInt::one(),
            Type::Bool => BigInt::one(),
            Type::Contract(_) => BigInt::from(ns.address_length),
            Type::Uint(n) => BigInt::from(n / 8),
            Type::Array(_, dims) if dims.last() == Some(&ArrayLength::Dynamic) => BigInt::from(4),
            Type::Array(ty, dims) => {
                let pointer_size = BigInt::from(4);

                ty.storage_slots(ns).mul(
                    dims.iter()
                        .map(|d| match d {
                            ArrayLength::Dynamic => &pointer_size,
                            ArrayLength::Fixed(d) => d,
                            ArrayLength::AnyFixed => {
                                panic!("unknown length");
                            }
                        })
                        .product::<BigInt>(),
                )
            }
            // TODO add struct storage offsets
            // Type::Struct(n) => ns.structs[*n]
            //     .storage_offsets
            //     .last()
            //     .cloned()
            //     .unwrap_or_else(BigInt::zero),
            Type::Function { .. } => BigInt::from(4),
            Type::Unresolved => BigInt::one(),
            Type::StorageRef(ty) => ty.storage_slots(ns),
            _ => unimplemented!(),
        }
    }

    /// Give the type of an memory array after dereference
    #[must_use]
    pub fn array_deref(&self) -> Self {
        match self {
            Type::Array(ty, dim) if dim.len() > 1 => {
                Type::Array(ty.clone(), dim[..dim.len() - 1].to_vec())
            }
            Type::Array(ty, dim) if dim.len() == 1 => *ty.clone(),
            _ => panic!("deref on non-array"),
        }
    }

    /// Alignment of elements in storage
    pub fn storage_align(&self, ns: &Namespace) -> BigInt {
        let length = match self {
            Type::Enum(_) => BigInt::one(),
            Type::Bool => BigInt::one(),
            Type::Contract(_) => BigInt::from(ns.address_length),
            Type::Uint(n) => BigInt::from(n / 8),
            Type::Array(_, dims) if dims.last() == Some(&ArrayLength::Dynamic) => BigInt::from(4),
            Type::Array(ty, _) => ty.storage_align(ns),
            Type::Struct(n) => ns.structs[*n]
                .fields
                .iter()
                .map(|field| {
                    if field.recursive {
                        BigInt::one()
                    } else {
                        field.ty.storage_align(ns)
                    }
                })
                .max()
                .unwrap(),
            Type::Unresolved => BigInt::one(),
            Type::StorageRef(ty) => ty.storage_align(ns),
            _ => unimplemented!(),
        };

        if length > BigInt::from(8) {
            BigInt::from(8)
        } else {
            length
        }
    }

    pub fn is_reference_type(&self, ns: &Namespace) -> bool {
        match self {
            Type::Bool => false,
            Type::Uint(_) => false,
            Type::Enum(_) => false,
            Type::Struct(_) => true,
            Type::Array(..) => true,
            Type::Contract(_) => false,
            Type::StorageRef(r) => r.is_reference_type(ns),
            Type::Function { .. } => false,
            Type::UserType(no) => ns.user_types[*no].ty.is_reference_type(ns),
            _ => false,
        }
    }

    /// Does this type contain any types which are variable-length
    pub fn is_dynamic(&self, ns: &Namespace) -> bool {
        match self {
            Type::Array(ty, dim) => {
                if dim.iter().any(|d| d == &ArrayLength::Dynamic) {
                    return true;
                }

                ty.is_dynamic(ns)
            }
            Type::Struct(n) => ns.structs[*n].fields.iter().any(|f| f.ty.is_dynamic(ns)),
            Type::StorageRef(r) => r.is_dynamic(ns),
            Type::Slice(_) => true,
            _ => false,
        }
    }

    /// Is this a reference to contract storage?
    pub fn is_contract_storage(&self) -> bool {
        matches!(self, Type::StorageRef(..))
    }

    /// If the type is Ref or StorageRef, get the underlying type
    pub fn deref_any(&self) -> &Self {
        match self {
            Type::StorageRef(r) => r,
            _ => self,
        }
    }

    /// If the type is Ref, get the underlying type
    pub fn deref_memory(&self) -> &Self {
        match self {
            _ => self,
        }
    }

    /// If the type is Ref or StorageRef, get the underlying type
    #[must_use]
    pub fn deref_into(self) -> Self {
        match self {
            Type::StorageRef(r) => *r,
            _ => self,
        }
    }

    /// Is it an address (with some sugar)
    pub fn is_address(&self) -> bool {
        matches!(self, Type::Contract(_))
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
