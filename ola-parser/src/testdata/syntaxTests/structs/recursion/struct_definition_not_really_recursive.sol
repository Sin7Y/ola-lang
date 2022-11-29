contract Test {
    struct S1 {
        u256 a;
    }
    struct S2 {
        S1 x;
        S1 y;
    }
}
// ----
