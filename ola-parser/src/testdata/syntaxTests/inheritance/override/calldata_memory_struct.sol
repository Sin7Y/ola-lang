pragma abicoder               v2;
contract A {
    u256 dummy;
    struct S { int a; }
    fn f(S calldata) external virtual pure {}
    fn g(S calldata) external virtual view { dummy; }
    fn h(S calldata) external virtual { dummy = 42; }
    fn i(S calldata) external virtual payable {}
}
contract B is A {
    fn f(S memory)  override pure {}
    fn g(S memory)  override view { dummy; }
    fn h(S memory)  override { dummy = 42; }
    fn i(S memory)  override payable {}
}
// ----
