contract C {
    fn f() public pure {
        if (false) {
            return; // unreachable, but not yet detected
        }
        return;
    }
}
// ----
