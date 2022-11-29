interface I {
    event A();
    fn f() external;
    fn g() external;
    fallback() external;
}
abstract contract C is I {
    fn f() public override {
    }
}
// ----
