interface I {
    fn f() external;
}
contract C is I {
    fn f() public override {
    }
}
// ----
