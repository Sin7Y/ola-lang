contract test {
    fallback() external {
        u256 x = 1;
        u256 y = 2;
        x || y;
    }
}
// ----
// TypeError 2271: (62-68): Operator || not compatible with types u256 and u256
