contract C {
    fn f(bytes calldata x) external {
        return this.f(x[1:2]);
    }
}
// ----
