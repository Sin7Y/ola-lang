pragma abicoder v2;

contract C {
    struct S {
        u256[] a;
    }

    fn f(S[]  c) external -> (u256, u256) {
        S[] memory s = c;
        assert(s.length == c.length);
        for (u256 i = 0; i < s.length; i++) {
            assert(s[i].a.length == c[i].a.length);
            for (u256 j = 0; j < s[i].a.length; j++) {
                assert(s[i].a[j] == c[i].a[j]);
            }
        }
        return (s[1].a.length, s[1].a[0]);
    }
}
// ====
// compileViaYul: also
// ----
// f((u256[])[]): 0x20, 3, 0x60, 0x60, 0x60, 0x20, 3, 1, 2, 3 -> 3, 1
