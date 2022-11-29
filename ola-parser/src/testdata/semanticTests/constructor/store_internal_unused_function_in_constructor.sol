contract C {
    fn() -> (u256) internal x;

    constructor() {
        x = unused;
    }

    fn unused() internal -> (u256) {
        return 7;
    }

    fn t() public -> (u256) {
        return x();
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// t() -> 7
