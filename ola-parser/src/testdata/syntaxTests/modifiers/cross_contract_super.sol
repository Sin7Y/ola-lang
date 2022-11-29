contract C {
    modifier m() { _; }
}
contract D is C {
    fn f() super.m  {
    }
}
// ----
// DeclarationError 7920: (74-81): Identifier not found or not unique.
