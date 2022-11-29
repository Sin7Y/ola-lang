


contract C {
    fn f(u256[][]  a)

        -> (u256, u256[] )
    {
        u256[]  m = a[0];
        return (a.length, m);
    }
}

// ====
// compileViaYul: also
// ----
// f(u256[][]): 0x20, 0x1, 0x20, 0x2, 0x17, 0x2a -> 0x1, 0x40, 0x2, 0x17, 0x2a
