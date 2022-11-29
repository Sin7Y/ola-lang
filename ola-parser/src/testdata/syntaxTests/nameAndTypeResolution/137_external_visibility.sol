contract c {
    fn f() external {}
    fn g() public { f(); }
}
// ----
// DeclarationError 7576: (68-69): Undeclared identifier. "f" is not (or not yet) visible at this point.
