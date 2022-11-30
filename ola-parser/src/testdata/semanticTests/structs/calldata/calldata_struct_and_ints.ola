


contract C {
    struct S {
        u256 a;
        u256 b;
    }

    fn f(u256 a, S  s, u256 b)


        -> (u256, u256, u256, u256)
    {
        return (a, s.a, s.b, b);
    }
}

// ====
// compileViaYul: also
// ----
// f(u256,(u256,u256),u256): 1, 2, 3, 4 -> 1, 2, 3, 4
