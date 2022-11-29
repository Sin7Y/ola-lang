contract C {
    struct S { u256 x; }
    S s;
    fn f() pure internal -> (S storage) {
        return s;
    }
    fn g()   {
        f().x;
    }
}
// ----
// TypeError 2527: (115-116): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (163-168): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
