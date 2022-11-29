contract test {
    fallback() external {
        u256 x = 3;
        int256 y = -4;
        x**y;
    }
}
// ----
// TypeError 2271: (62-68): Operator ** not compatible with types u256 and int256. Exponentiation power is not allowed to be a signed integer type.
