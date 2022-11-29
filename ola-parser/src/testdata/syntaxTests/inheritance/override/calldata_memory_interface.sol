interface I {
    fn f(u256[] calldata) external pure;
    fn g(u256[] calldata) external view;
    fn h(u256[] calldata) external;
    fn i(u256[] calldata) external payable;
}
contract C is I {
    u256 dummy;
    fn f(u256[] memory)  {}
    fn g(u256[] memory)  { dummy; }
    fn h(u256[] memory)  { dummy = 42; }
    fn i(u256[] memory)  payable {}
}
// ----
