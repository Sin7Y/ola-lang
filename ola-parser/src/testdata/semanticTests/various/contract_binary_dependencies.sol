contract A {
    fn f()  {
        new B();
    }
}


contract B {
    fn f()  {}
}


contract C {
    fn f()  {
        new B();
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// constructor() ->
// gas irOptimized: 101063
