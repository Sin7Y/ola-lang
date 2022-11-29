contract C {
    fn f()  ->(u256) {
        return 2e10 wei;
    }

    fn g()  ->(u256) {
        return 200e-2 wei;
    }

    fn h()  ->(u256) {
        return 2.5e1;
    }

    fn i()  ->(int) {
        return -2e10;
    }

    fn j()  ->(int) {
        return -200e-2;
    }

    fn k()  ->(int) {
        return -2.5e1;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 20000000000
// g() -> 2
// h() -> 25
// i() -> -20000000000
// j() -> -2
// k() -> -25
