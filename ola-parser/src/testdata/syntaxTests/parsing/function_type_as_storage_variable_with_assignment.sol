contract test {
    fn f(uint x, uint y) public returns (uint a) {}
    fn (uint, uint) internal returns (uint) f1 = f;
}
// ----
