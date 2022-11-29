contract C {
    struct S {
        u256 x;
    }
    S s;

    fn g() internal -> (u256, S storage, u256) {
        s.x = 7;
        return (1, s, 2);
    }

    fn f()  -> (bool) {
        (u256 x1, S storage y1, u256 z1) = g();
        if (x1 != 1 || y1.x != 7 || z1 != 2) return false;
        (, S storage y2, ) = g();
        if (y2.x != 7) return false;
        (u256 x2, , ) = g();
        if (x2 != 1) return false;
        (, , u256 z2) = g();
        if (z2 != 2) return false;
        return true;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> true
