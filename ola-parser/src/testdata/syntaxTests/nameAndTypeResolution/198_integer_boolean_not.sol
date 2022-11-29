contract test {
    fallback() external {
        u256 x = 1;
        !x;
    }
}
// ----
// TypeError 4907: (50-52): Unary operator ! cannot be applied to type u256
