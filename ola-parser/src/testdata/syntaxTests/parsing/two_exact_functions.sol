// with support of overloaded functions, during parsing,
// we can't determine whether they match exactly, however
// it will throw DeclarationError in following stage.
contract test {
    fn fun(uint a) public returns(uint r) { return a; }
    fn fun(uint a) public returns(uint r) { return a; }
}
// ----
// DeclarationError 1686: (189-246): fn with same name and parameter types defined twice.
