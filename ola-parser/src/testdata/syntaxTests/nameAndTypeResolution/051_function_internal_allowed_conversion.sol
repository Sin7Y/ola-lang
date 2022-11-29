contract C {
    uint a;
}
contract Test {
    C a;
    fn g (C c) public {}
    fn internalCall() public {
        g(a);
    }
}
// ----
