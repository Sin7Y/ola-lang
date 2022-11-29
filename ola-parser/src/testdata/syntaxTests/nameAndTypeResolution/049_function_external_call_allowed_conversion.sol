contract C {}
contract Test {
    fn externalCall() public {
        C arg;
        this.g(arg);
    }
    fn g (C c) external {}
}
// ----
