pragma abicoder               v2;

contract C {
    struct S {
        bool[] b;
    }

    fn f()  -> (u256, bool[][2] memory, S[2] memory, u256) {
        return (
            5,
            [new bool[](1), new bool[](2)],
            [S(new bool[](2)), S(new bool[](5))],
            6
        );
    }

    fn g()  -> (u256, u256) {
        (u256 a, , , u256 b) = this.f();
        return (a, b);
    }
}
// ====
// compileViaYul: also
// ----
// g() -> 5, 6
