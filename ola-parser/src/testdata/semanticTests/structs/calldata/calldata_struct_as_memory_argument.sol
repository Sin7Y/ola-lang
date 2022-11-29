

contract C {
    struct S {
        u256 p1;
        u256[][2] a;
        u32 p2;
    }

    fn g(u32 p1, S  s)  ->(u32, u256, u256, u256, u32) {
        s.p1++;
        s.a[0][1]++;
        return (p1, s.p1, s.a[0][0], s.a[1][1], s.p2);
    }

    fn f(u32 p1, S  c)  ->(u32, u256, u256, u256, u32) {
        return g(p1, c);
    }
}
// ====
// compileViaYul: also
// ----
// f(u32,(u256,u256[][2],u32)): 55, 0x40, 77, 0x60, 88, 0x40, 0x40, 2, 1, 2 -> 55, 78, 1, 2, 88
