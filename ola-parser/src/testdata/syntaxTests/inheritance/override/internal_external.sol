contract A {
    fn f(u256[] calldata) external pure {}
    fn f(u256[] memory) internal pure {}
}
// ----
// DeclarationError 1686: (17-61): fn with same name and parameter types defined twice.
