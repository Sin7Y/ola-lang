contract C {
    u256 public x;
    modifier setsx {
        _;
        x = 9;
    }

    fn f() public setsx -> (u256) {
        return 2;
    }
}

// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// x() -> 0
// f() -> 2
// x() -> 9
