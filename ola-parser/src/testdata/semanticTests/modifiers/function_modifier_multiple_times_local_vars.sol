contract C {
    u256 public a;
    modifier mod(u256 x) {
        u256 b = x;
        a += b;
        _;
        a -= b;
        assert(b == x);
    }

    fn f(u256 x) public mod(2) mod(5) mod(x) -> (u256) {
        return a;
    }
}

// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f(u256): 3 -> 10
// a() -> 0
