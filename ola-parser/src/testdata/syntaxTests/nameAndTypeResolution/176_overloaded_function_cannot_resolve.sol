contract test {
    fn f() public returns (uint) { return 1; }
    fn f(uint a) public returns (uint) { return a; }
    fn g() public returns (uint) { return f(3, 5); }
}
// ----
// TypeError 9322: (176-177): No matching declaration found after argument-dependent lookup.
