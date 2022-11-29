contract A {
    u256 dummy;
    fn f(u256[] calldata) external virtual pure {}
    fn g(u256[] calldata) external virtual view { dummy; }
    fn h(u256[] calldata) external virtual { dummy = 42; }
    fn i(u256[] calldata) external virtual payable {}
}
contract B is A {
    fn f(u256[] memory)  override pure {}
    fn g(u256[] memory)  override view { dummy; }
    fn h(u256[] memory)  override { dummy = 42; }
    fn i(u256[] memory)  override payable {}
}
// ----
