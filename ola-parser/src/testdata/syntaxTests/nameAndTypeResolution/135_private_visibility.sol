contract base {
    fn f() private {}
}
contract derived is base {
    fn g() public { f(); }
}
// ----
// DeclarationError 7576: (99-100): Undeclared identifier.
