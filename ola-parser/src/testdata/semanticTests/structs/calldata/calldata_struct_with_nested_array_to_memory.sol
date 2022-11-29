

contract C {
    struct S {
        u256 p1;
        u256[][2] a;
        u32 p2;
    }
    fn f(u32 p1, S  c)  ->(u32, u256, u256, u256, u32) {
        S  s = c;
        assert(s.a[0][0] == c.a[0][0]);
        assert(s.a[1][1] == c.a[1][1]);
        s.p1++;
        assert(s.p1 != c.p1);
        s.a[0][1]++;
        assert(s.a[0][1] != c.a[0][1]);
        return (p1, s.p1, s.a[0][0], s.a[1][1], s.p2);
    }
}
// ====
// compileViaYul: also
// ----
// f(u32,(u256,u256[][2],u32)): 55, 0x40, 77, 0x60, 88, 0x40, 0x40, 2, 1, 2 -> 55, 78, 1, 2, 88
