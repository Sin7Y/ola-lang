contract Test {
    struct S {
        u32 x;
        u32 y;
        u256 z;
    }

    fn test()  -> (u256 x, u256 y, u256 z) {
        S  data = combine(1, 2, 3);
        x = extract(data, 0);
        y = extract(data, 1);
        z = extract(data, 2);
    }

    fn extract(S  s, u256 which)  -> (u256 x) {
        if (which == 0) return s.x;
        else if (which == 1) return s.y;
        else return s.z;
    }

    fn combine(u32 x, u32 y, u256 z)

        -> (S  s)
    {
        s.x = x;
        s.y = y;
        s.z = z;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// test() -> 1, 2, 3
