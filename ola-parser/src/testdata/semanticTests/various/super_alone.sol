contract A {
    fn f()  {
        super;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() ->
