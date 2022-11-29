contract test {
    fn fun() public { }
    fn fun() public { }
}
// ----
// DeclarationError 1686: (20-45): fn with same name and parameter types defined twice.
