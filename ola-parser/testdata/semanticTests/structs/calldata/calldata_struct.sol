pragma abicoder               v2;


contract C {
    struct S {
        u256 a;
        u256 b;
    }

    fn f(S  s) external pure -> (u256 a, u256 b) {
        a = s.a;
        b = s.b;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f((u256,u256)): 42, 23 -> 42, 23
