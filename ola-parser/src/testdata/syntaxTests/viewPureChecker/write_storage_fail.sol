contract C {
    u256 x;
    fn f() view  { x = 2; }
}
// ----
// TypeError 8961: (56-57): fn cannot be declared as view because this expression (potentially) modifies the state.
