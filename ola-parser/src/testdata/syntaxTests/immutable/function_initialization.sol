contract C {
    uint immutable x = f();

    fn f() public pure returns (uint) { return 3; }
}
// ----
