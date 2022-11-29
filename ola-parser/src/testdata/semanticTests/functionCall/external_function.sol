contract c {
    fn f(u256 a) public -> (u256) {
        return a;
    }

    fn test(u256 a, u256 b)
        external
        -> (u256 r_a, u256 r_b)
    {
        r_a = f(a + 7);
        r_b = b;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// test(u256,u256): 2, 3 -> 9, 3
