contract C {
    fn test(uint a) public returns (uint b) { }
    fn test(uint a) external {}
}
// ----
// DeclarationError 1686: (17-66): fn with same name and parameter types defined twice.
