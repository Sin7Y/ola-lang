pragma abicoder               v2;

contract C {
    struct S {
        u256 a;
        bool x;
    }

    fn s() public ->(S memory)
    {
        return S({x: true, a: 8});
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// s() -> 8, true
