//! Types of IR values.
//!
//! Each IR value and function should have a type.

use std::cell::{Cell, RefCell};
use std::collections::HashMap;
use std::rc::Rc;
use std::{cmp, fmt, hash, mem};

/// Kind of type.
#[derive(Hash, Clone, PartialEq, Eq)]
pub enum TypeKind {
    /// integer.
    Uint32,
    Uint64,
    Uint256,
    /// boolean.
    Bool,
    /// field.
    Field,
    /// Array (base type + length).
    Array(Type, usize),
    /// Pointer (base type).
    Pointer(Type),
    /// Function (parameter types + return type).
    Function(Vec<Type>, Type),
}

impl fmt::Display for TypeKind {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            TypeKind::Uint32 => write!(f, "u32"),
            TypeKind::Uint64 => write!(f, "u64"),
            TypeKind::Uint256 => write!(f, "u256"),
            TypeKind::Bool => write!(f, "bool"),
            TypeKind::Field => write!(f, "field"),
            TypeKind::Array(t, len) => write!(f, "[{}, {}]", t, len),
            TypeKind::Pointer(t) => write!(f, "*{}", t),
            TypeKind::Function(params, ret) => {
                write!(f, "(")?;
                let mut first = true;
                for param in params {
                    if !first {
                        write!(f, ", ")?;
                    }
                    write!(f, "{}", param)?;
                    first = false;
                }
                write!(f, "): {}", ret)
            }
        }
    }
}

/// Types of IR values.
#[derive(Clone, Eq)]
pub struct Type(Rc<TypeKind>);

impl Type {
    thread_local! {
      /// Pool of all created types.
      static POOL: RefCell<HashMap<TypeKind, Type>> = RefCell::new(HashMap::new());

      /// Size of pointers.
      static PTR_SIZE: Cell<usize> = Cell::new(mem::size_of::<*const ()>());
    }

    /// Returns a type by the given [`TypeKind`].
    pub fn get(type_data: TypeKind) -> Type {
        Self::POOL.with(|pool| {
            let mut pool = pool.borrow_mut();
            pool.get(&type_data).cloned().unwrap_or_else(|| {
                let v = Self(Rc::new(type_data.clone()));
                pool.insert(type_data, v.clone());
                v
            })
        })
    }

    /// Returns an `uint32` type.
    pub fn get_u32() -> Type {
        Type::get(TypeKind::Uint32)
    }

    /// Returns an `uint64` type.
    pub fn get_u64() -> Type {
        Type::get(TypeKind::Uint64)
    }

    /// Returns an `uint256` type.
    pub fn get_u256() -> Type {
        Type::get(TypeKind::Uint256)
    }

    /// Returns an `bool` type.
    pub fn get_unit() -> Type {
        Type::get(TypeKind::Bool)
    }

    /// Returns an `field` type.
    pub fn get_field() -> Type {
        Type::get(TypeKind::Field)
    }

    /// Returns an `array` type.
    pub fn get_array(base: Type, len: usize) -> Type {
        assert!(len != 0, "`len` can not be zero!");
        Type::get(TypeKind::Array(base, len))
    }

    /// Returns an `pointer` type.
    pub fn get_pointer(base: Type) -> Type {
        Type::get(TypeKind::Pointer(base))
    }

    /// Returns an `function` type.
    pub fn get_function(params: Vec<Type>, ret: Type) -> Type {
        Type::get(TypeKind::Function(params, ret))
    }

    /// Sets the size of pointers.
    pub fn set_ptr_size(size: usize) {
        Self::PTR_SIZE.with(|ptr_size| ptr_size.set(size));
    }

    /// Returns a reference to the kind of the current type.
    pub fn kind(&self) -> &TypeKind {
        &self.0
    }

    /// Checks if the current type is an U32 type.
    pub fn is_U32(&self) -> bool {
        matches!(self.0.as_ref(), TypeKind::Uint32)
    }

    /// Checks if the current type is an U32 type.
    pub fn is_U64(&self) -> bool {
        matches!(self.0.as_ref(), TypeKind::Uint64)
    }

    /// Checks if the current type is an U32 type.
    pub fn is_U256(&self) -> bool {
        matches!(self.0.as_ref(), TypeKind::Uint256)
    }

    /// Checks if the current type is a bool type.
    pub fn is_bool(&self) -> bool {
        matches!(self.0.as_ref(), TypeKind::Bool)
    }

    /// Checks if the current type is a field type.
    pub fn is_field(&self) -> bool {
        matches!(self.0.as_ref(), TypeKind::Field)
    }

    /// Returns the size of the current type in bytes.
    pub fn size(&self) -> usize {
        match self.kind() {
            TypeKind::Uint32 => 4,
            TypeKind::Uint64 | TypeKind::Field => 8,
            TypeKind::Uint256 => 32,
            TypeKind::Bool => 1,
            TypeKind::Array(ty, len) => ty.size() * len,
            TypeKind::Pointer(..) | TypeKind::Function(..) => Self::PTR_SIZE.with(|s| s.get()),
        }
    }
}

impl cmp::PartialEq for Type {
    fn eq(&self, other: &Self) -> bool {
        Rc::ptr_eq(&self.0, &other.0)
    }
}

impl fmt::Display for Type {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl fmt::Debug for Type {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl hash::Hash for Type {
    fn hash<H: hash::Hasher>(&self, state: &mut H) {
        self.0.hash(state);
    }
}
