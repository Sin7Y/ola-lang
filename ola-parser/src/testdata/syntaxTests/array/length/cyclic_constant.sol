contract C {
    uint constant LEN = LEN;
    fn f() public {
        uint[LEN] a;
    }
}
// ----
// TypeError 5210: (17-40): Cyclic constant definition (or maximum recursion depth exhausted).
