abstract contract D {
    fn g() public virtual;
}


contract C {
    D d = D(address(0x1212));

    fn f() public -> (u256) {
        d.g();
        return 7;
    }

    fn g() public -> (u256) {
        d.g{gas: 200}();
        return 7;
    }

    fn h() public -> (u256) {
        address(d).call(""); // this does not throw (low-level)
        return 7;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> FAILURE
// g() -> FAILURE
// h() -> 7
