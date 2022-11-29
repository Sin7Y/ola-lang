contract test {
    fn f(uint a) public returns (uint) { return 2 * a; }
    fn g() public returns (uint) { fn (uint) returns (uint) x = f; return x(7); }
}
// ----
// Warning 2018: (20-78): fn state mutability can be restricted to pure
