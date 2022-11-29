contract test {
    fn f() public returns (uint) { return 1; }
    fn f(uint a) public returns (uint) { return 2 * a; }
    fn g() public returns (uint) { fn (uint) returns (uint) x = f; return x(7); }
}
// ----
// TypeError 2144: (208-209): No matching declaration found after variable lookup.
