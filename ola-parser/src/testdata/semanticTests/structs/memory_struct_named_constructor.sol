

contract C {
    struct S {
        u256 a;
        bool x;
    }

    fn s()  ->(S )
    {
        return S({x: true, a: 8});
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// s() -> 8, true
