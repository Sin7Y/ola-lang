contract C {
    struct S {
        u256 a;
    }
    S s;
    mapping (u256 => S) m;

    fn f() external -> (bool) {
        s.a = 12;
        m[1] = s;
        return m[1].a == 12;
    }
}
// ====
// compileViaYul: also
// ----
// f() -> true
