contract D {}
contract C {
    fn f()  { new D(); }
}
// ----
// TypeError 8961: (58-65): fn cannot be declared as view because this expression (potentially) modifies the state.
