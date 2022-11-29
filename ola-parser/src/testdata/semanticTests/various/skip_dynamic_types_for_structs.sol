// For accessors, the dynamic types are already removed in the external signature itself.
contract C {
    struct S {
        u256 x;
        string a; // this is present in the accessor
        u256[] b; // this is not present
        u256 y;
    }
    S  s;

    fn g()  -> (u256, u256) {
        s.x = 2;
        s.a = "abc";
        s.b = [7, 8, 9];
        s.y = 6;
        (u256 x, , u256 y) = this.s();
        return (x, y);
    }
}

// ====
// compileViaYul: also
// ----
// g() -> 2, 6
// gas irOptimized: 178805
// gas legacy: 180753
// gas legacyOptimized: 179472
