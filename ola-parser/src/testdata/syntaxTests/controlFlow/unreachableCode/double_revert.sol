contract C {
    fn f() public pure {
        revert();
        revert();
    }
}
// ----
// Warning 5740: (70-78): Unreachable code.
