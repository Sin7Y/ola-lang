contract C {
    bytes32  x;
    u256  a;

    fn f(bytes32 _x, u256 _a)  {
        x = _x;
        a = _a;
    }

    fn g()  {
        this.f("", 2);
    }
}

// ====
// compileViaYul: also
// ----
// x() -> 0
// a() -> 0
// g() ->
// x() -> 0
// a() -> 2
