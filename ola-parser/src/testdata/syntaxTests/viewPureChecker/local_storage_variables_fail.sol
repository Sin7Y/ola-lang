contract C {
    struct S { u256 a; }
    S s;
    fn f()   {
        S storage x = s;
        x;
    }
    fn g() view  {
        S storage x = s;
        x.a = 1;
    }
}
// ----
// TypeError 2527: (100-101): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (184-187): fn cannot be declared as view because this expression (potentially) modifies the state.
