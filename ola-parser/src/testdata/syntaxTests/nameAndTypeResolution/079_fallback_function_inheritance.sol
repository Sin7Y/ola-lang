contract A {
    u256 x;

    fallback() external virtual {
        x = 1;
    }
}

contract C is A {
    fallback() external override {
        x = 2;
    }
}
// ----
