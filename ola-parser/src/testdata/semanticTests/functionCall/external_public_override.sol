contract A {
    fn f() external virtual -> (u256) {
        return 1;
    }
}


contract B is A {
    fn f() public override -> (u256) {
        return 2;
    }

    fn g() public -> (u256) {
        return f();
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 2
// g() -> 2
