use once_cell::sync::Lazy;
use crate::irgen::binary::Binary;
use crate::sema::ast::Namespace;

const EPSILON: u64 = (1 << 32) - 1;

/// A field selected to have fast reduction.
///
/// Its order is 2^64 - 2^32 + 1.
/// P = 2**64 - EPSILON
///   = 2**64 - 2**32 + 1
///   = 2**32 * (2**32 - 1) + 1
///
pub const ORDER: u64 = 0xFFFFFFFF00000001;

static PROPHET_FUNCTIONS: Lazy<[&str; 1]> = Lazy::new(|| [
    "prophet_u32_sqrt",

]);

static BUILTIN_FUNCTIONS: Lazy<[&str; 1]> = Lazy::new(|| [
    "builtin_assert",
]);

// These functions will be called implicitly by corelib
// May later become corelib functions open to the user as well
static IMPLICIT_CALLED_FUNCTIONS: Lazy<[&str; 2]> = Lazy::new(|| [
    "field_modulo",
    "assert",
]);


// Generate core lib functions ir
pub fn gen_lib_functions<'a>(bin: &mut Binary<'a>, ns: &Namespace) {

    declare_prophets(bin, ns);

    declare_builtins(bin, ns);

    //Generate some functions that are called implicitly
    IMPLICIT_CALLED_FUNCTIONS.iter().for_each(|p| {
        match *p {
            "modulo" => {

            },
            "assert" => {

            }
            _ => {}
        }
    });

    // Generate core lib functions
    ns.called_lib_functions.iter().for_each(|p| {
        match p.as_str() {
            "u32_sqrt" => {

            },
            _ => {}
        }
    });


}


// Declare the prophet functions
pub fn declare_prophets<'a>(bin: &mut Binary<'a>, ns: &Namespace) {

    PROPHET_FUNCTIONS.iter().for_each(|p| {
        match *p {
            "prophet_sqrt" => {

            }
            _ => {}
        }
    });


}

// Declare the builtin functions without function body
pub fn declare_builtins<'a>(bin: &mut Binary<'a>, ns: &Namespace) {
    BUILTIN_FUNCTIONS.iter().for_each(|p| {
        match *p {
            "builtin_assert" => {

            }
            _ => {}
        }
    });



}