contract C {
    fn f() public pure {
        return;
        // unreachable comment
    }
}
// ----
