

contract C {
    struct S {
        u256 p1;
        u256[][2] a;
        u32 p2;
    }

    struct S1 {
        u256 u;
        S s;
    }

    struct S2 {
        S[2] array;
    }

    fn f1(S1  c)  ->(S1 ) {
        return c;
    }

    fn f(S1  c, u32 p)  ->(u32, u256, u256, u256, u32) {
        S1  m = f1(c);
        assert(m.s.a[0][0] == c.s.a[0][0]);
        assert(m.s.a[1][1] == c.s.a[1][1]);
        return (p, m.s.p1, m.s.a[0][0], m.s.a[1][1], m.s.p2);
    }

    fn g(S2  c)  ->(u256, u256, u256, u32) {
        S2  m = c;
        assert(m.array[0].a[0][0] == c.array[0].a[0][0]);
        assert(m.array[0].a[1][1] == c.array[0].a[1][1]);
        return (m.array[1].p1, m.array[1].a[0][0], m.array[1].a[1][1], m.array[1].p2);
    }

    fn h(S1  c, u32 p)  ->(u32, u256, u256, u256, u32) {
        S  m = c.s;
        assert(m.a[0][0] == c.s.a[0][0]);
        assert(m.a[1][1] == c.s.a[1][1]);
        return (p, m.p1, m.a[0][0], m.a[1][1], m.p2);
    }
}
// ====
// compileViaYul: also
// ----
// f((u256,(u256,u256[][2],u32)),u32): 0x40, 44, 11, 0x40, 22, 0x60, 33, 0x40, 0x40, 2, 1, 2 -> 44, 22, 1, 2, 33
// g(((u256,u256[][2],u32)[2])): 0x20, 0x20, 0x40, 0x40, 22, 0x60, 33, 0x40, 0x40, 2, 1, 2 -> 22, 1, 2, 33
// h((u256,(u256,u256[][2],u32)),u32): 0x40, 44, 11, 0x40, 22, 0x60, 33, 0x40, 0x40, 2, 1, 2 -> 44, 22, 1, 2, 33
