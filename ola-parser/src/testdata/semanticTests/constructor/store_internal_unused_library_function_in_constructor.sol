library L {
    fn x() internal -> (u256) {
        return 7;
    }
}


contract C {
    fn() -> (u256) internal x;

    constructor() {
        x = L.x;
    }

    fn t() public -> (u256) {
        return x();
    }
}

// ====
// compileViaYul: also
// ----
// t() -> 7
