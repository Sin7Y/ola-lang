contract C {
    u256 x;
    fn f()   { g(); }
    fn g() view  { x; }
    fn h() view  { i(); }
    fn i()  { x = 2; }
}
// ----
// TypeError 2527: (56-59): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
// TypeError 8961: (130-133): fn cannot be declared as view because this expression (potentially) modifies the state.
