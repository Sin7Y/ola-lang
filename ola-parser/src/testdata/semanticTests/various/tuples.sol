contract C {
    u256[] data;
    u256[] m_c;

    fn g() internal -> (u256 a, u256 b, u256[] storage c) {
        return (1, 2, data);
    }

    fn h() external -> (u256 a, u256 b) {
        return (5, 6);
    }

    fn f()  -> (u256) {
        data.push(3);
        u256 a;
        u256 b;
        (a, b) = this.h();
        if (a != 5 || b != 6) return 1;
        u256[] storage c = m_c;
        (a, b, c) = g();
        if (a != 1 || b != 2 || c[0] != 3) return 2;
        (a, b) = (b, a);
        if (a != 2 || b != 1) return 3;
        (a, , b, , ) = (8, 9, 10, 11, 12);
        if (a != 8 || b != 10) return 4;
    }
}
// ====
// compileViaYul: also
// ----
// f() -> 0
