contract c {
    event e(uint a, bytes3 indexed s, bool indexed b);
    fn f() public { emit e(2, "abc", true); }
}
// ----
