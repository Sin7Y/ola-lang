contract A {
    u256 x;
}

contract B is A {
    fn f()  -> (u256) {
        return A.x;
    }
    fn g()  {
        A.x = 5;
    }
}
// ----
// TypeError 2527: (107-110): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (157-160): fn cannot be declared as view because this expression (potentially) modifies the state.
