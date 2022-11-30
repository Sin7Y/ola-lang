contract Test {
    struct S {
        uint8 x;
        u32 y;
        u256 z;
    }

    fn test()  -> (u256 x, u256 y, u256 z) {
        S memory data = combine(1, 2, 3);
        x = extract(data, 0);
        y = extract(data, 1);
        z = extract(data, 2);
    }

    fn extract(S memory s, u256 which) internal -> (u256 x) {
        if (which == 0) return s.x;
        else if (which == 1) return s.y;
        else return s.z;
    }

    fn combine(uint8 x, u32 y, u256 z)
        internal
        -> (S memory s)
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
