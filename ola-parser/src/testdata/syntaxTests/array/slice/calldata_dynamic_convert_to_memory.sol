contract C {
    fn f(bytes calldata x) external pure returns (bytes memory) {
        return x[1:2];
    }
}
// ----
