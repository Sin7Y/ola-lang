library L {
    fn a() public pure {}
    fn b() public pure { a(); }
}
// ----
