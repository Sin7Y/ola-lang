contract C {
    uint public f = 0;
    fn f(uint) public pure {}
}
// ----
// DeclarationError 2333: (40-71): Identifier already declared.
