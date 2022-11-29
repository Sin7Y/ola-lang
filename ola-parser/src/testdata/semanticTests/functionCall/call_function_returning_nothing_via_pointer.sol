contract test {
    bool  flag = false;

    fn f0()  {
        flag = true;
    }

    fn f()  -> (bool) {
        fn() internal x = f0;
        x();
        return flag;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> true
// flag() -> true
