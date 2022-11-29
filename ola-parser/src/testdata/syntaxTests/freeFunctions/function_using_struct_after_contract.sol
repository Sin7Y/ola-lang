contract C {
    struct S { u256 x; }
}
fn f() -> (u256) { S storage t; }
// ----
// DeclarationError 7920: (70-71): Identifier not found or not unique.
