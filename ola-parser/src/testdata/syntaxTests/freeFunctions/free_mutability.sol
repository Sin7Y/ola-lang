fn f() {
    u256 x = 2;
    x;
}
fn g(u256[] storage x) pure { x[0] = 1; }
// ----
// Warning 2018: (0-39): fn state mutability can be restricted to pure
// TypeError 8961: (76-80): fn cannot be declared as pure because this expression (potentially) modifies the state.
