contract C {
    struct S {
        u256 x;
        uint128 y;
        uint32 z;
    }
    uint8 b = 23;
    S s;
    uint8 a = 17;
    fn f() public {
        s.x = 42; s.y = 42; s.y = 42;
        delete s;
        assert(s.x == 0);
        assert(s.y == 0);
        assert(s.z == 0);
        assert(b == 23);
        assert(a == 17);
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() ->
