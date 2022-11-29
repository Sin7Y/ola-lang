contract A {
    struct S { u256 x; }
    S s;
}

contract B is A {
    fn f()  {
        A.s = A.S(2);
    }
    fn g()  {
        A.s.x = 2;
    }
    fn h()  -> (u256) {
        return A.s.x;
    }
}
// ----
// TypeError 8961: (107-110): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (166-171): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 2527: (244-247): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 2527: (244-249): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
