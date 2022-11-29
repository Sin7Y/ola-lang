contract c {
    fn f(uint a) external { delete a; }
}
// ----
// Warning 2018: (17-58): fn state mutability can be restricted to pure
