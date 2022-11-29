contract C {
    u256 x;
    fn g()  -> (u256) { return x; }
}
// ----
// Warning 2018: (29-77): fn state mutability can be restricted to view
