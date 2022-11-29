contract B {
    fn f() mod(x)   { u256 x = 7; }
    modifier mod(u256 a) { if (a > 0) _; }
}
// ----
// DeclarationError 7576: (34-35): Undeclared identifier.
