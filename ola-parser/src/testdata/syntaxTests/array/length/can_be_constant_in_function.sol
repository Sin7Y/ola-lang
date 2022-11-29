contract C {
    uint constant LEN = 10;
    fn f() public pure {
        uint[LEN] memory a;
        a;
    }
}
// ----
