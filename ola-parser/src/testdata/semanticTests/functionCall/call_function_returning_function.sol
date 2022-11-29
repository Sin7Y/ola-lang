contract test {
    fn f0()  -> (u256) {
        return 2;
    }

    fn f1() internal -> (fn() internal -> (u256)) {
        return f0;
    }

    fn f2() internal -> (fn() internal -> (fn () internal -> (u256))) {
        return f1;
    }

    fn f3() internal -> (fn() internal -> (fn () internal -> (fn () internal -> (u256)))) {
        return f2;
    }

    fn f()  -> (u256) {
        fn() internal ->(fn() internal ->(fn() internal ->(fn() internal ->(u256)))) x;
        x = f3;
        return x()()()();
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 2
