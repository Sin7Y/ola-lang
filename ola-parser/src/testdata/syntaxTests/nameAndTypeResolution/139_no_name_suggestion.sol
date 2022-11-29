contract c {
    fn g() public { fun(); }
}
// ----
// DeclarationError 7576: (39-42): Undeclared identifier.
