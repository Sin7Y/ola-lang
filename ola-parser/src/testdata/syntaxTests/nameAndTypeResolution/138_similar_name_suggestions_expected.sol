contract c {
    fn func() public {}
    fn g() public { fun(); }
}
// ----
// DeclarationError 7576: (69-72): Undeclared identifier. Did you mean "func"?
