contract C {
    u256 x;
    fn f()  -> (u256) {
        return x;
    }
}
// ----
// TypeError 2527: (86-87): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
