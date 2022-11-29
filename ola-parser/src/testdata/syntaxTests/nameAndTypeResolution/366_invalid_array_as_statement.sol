contract test {
    struct S {
        u256 x;
    }

    constructor(u256 k) {
        S[k];
    }
}
// ----
// TypeError 3940: (69-70): Integer constant expected.
