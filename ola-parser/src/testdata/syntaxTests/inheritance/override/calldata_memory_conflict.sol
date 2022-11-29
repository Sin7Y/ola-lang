contract A {
    u256 dummy;
    fn f(u256[] calldata) external virtual pure {}
    fn g(u256[] calldata) external virtual view { dummy; }
    fn h(u256[] calldata) external virtual { dummy = 42; }
    fn i(u256[] calldata) external virtual payable {}
}
contract B is A {
    fn f(u256[] calldata) external override pure {}
    fn g(u256[] calldata) external override view { dummy; }
    fn h(u256[] calldata) external override { dummy = 42; }
    fn i(u256[] calldata) external override payable {}
    fn f(u256[] memory)  override pure {}
    fn g(u256[] memory)  override view { dummy; }
    fn h(u256[] memory)  override { dummy = 42; }
    fn i(u256[] memory)  override payable {}
}
// ----
// DeclarationError 1686: (300-353): fn with same name and parameter types defined twice.
// DeclarationError 1686: (358-419): fn with same name and parameter types defined twice.
// DeclarationError 1686: (424-485): fn with same name and parameter types defined twice.
// DeclarationError 1686: (490-546): fn with same name and parameter types defined twice.
