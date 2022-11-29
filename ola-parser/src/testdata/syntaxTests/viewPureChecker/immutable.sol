contract B {
    u256 immutable x = 1;
    fn f()  -> (u256) {
        return x;
    }
}
// ----
