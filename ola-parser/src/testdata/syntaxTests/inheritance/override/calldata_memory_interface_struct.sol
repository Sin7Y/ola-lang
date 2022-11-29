pragma abicoder               v2;
interface I {
    struct S { int a; }
    fn f(S calldata) external pure;
    fn g(S calldata) external view;
    fn h(S calldata) external;
    fn i(S calldata) external payable;
}
contract C is I {
    u256 dummy;
    fn f(S memory)  override pure {}
    fn g(S memory)  { dummy; }
    fn h(S memory)  override { dummy = 42; }
    fn i(S memory)  payable {}
}
// ----
