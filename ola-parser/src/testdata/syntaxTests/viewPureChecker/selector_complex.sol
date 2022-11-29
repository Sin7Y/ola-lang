contract C {
    fn f(C c)   -> (C) {
        return c;
    }
    fn g()   -> (bytes4) {
        // By passing `this`, we read from the state, even if f itself is pure.
        return f(this).f.selector;
    }
}
// ----
// TypeError 2527: (228-232): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
