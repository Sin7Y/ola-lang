contract test {
    fn f(uint8 a) public returns (uint) { return a; }
    fn f(uint a) public returns (uint) { return 2 * a; }
    // literal 1 can be both converted to uint and uint8, so the call is ambiguous.
    fn g() public returns (uint) { return f(1); }
}
// ----
// TypeError 4487: (271-272): No unique declaration found after argument-dependent lookup.
