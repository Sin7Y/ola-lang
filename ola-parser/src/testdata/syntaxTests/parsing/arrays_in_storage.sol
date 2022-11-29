contract c {
    u256[10] a;
    u256[] a2;
    struct x {
        u256[2**20] b;
        y[1] c;
    }
    struct y {
        u256 d;
        mapping(u256 => x)[] e;
    }
}
// ----
