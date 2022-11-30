contract Test {
    struct S {
        uint8 x;
        u32 y;
        u256 z;
    }
    struct X {
        uint8 x;
        S s;
    }

    fn test()
        
        -> (u256 a, u256 x, u256 y, u256 z)
    {
        X memory d = combine(1, 2, 3, 4);
        a = extract(d, 0);
        x = extract(d, 1);
        y = extract(d, 2);
        z = extract(d, 3);
    }

    fn extract(X memory s, u256 which) internal -> (u256 x) {
        if (which == 0) return s.x;
        else if (which == 1) return s.s.x;
        else if (which == 2) return s.s.y;
        else return s.s.z;
    }

    fn combine(uint8 a, uint8 x, u32 y, u256 z)
        internal
        -> (X memory s)
    {
        s.x = a;
        s.s.x = x;
        s.s.y = y;
        s.s.z = z;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// test() -> 1, 2, 3, 4
