contract C {
    u256 x;

    fallback() external {
        x = 2;
    }
}
// ----
