contract A {
    u256[] x;
    fn f()  -> (u256) {
        return x.push();
    }
}
// ----
// TypeError 8961: (88-96): fn cannot be declared as view because this expression (potentially) modifies the state.
