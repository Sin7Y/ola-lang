contract C {
    fn f(bytes calldata x) external pure {
        x[1:2];
    }
}
// ----
