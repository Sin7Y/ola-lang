contract test {
    fn f(uint x, uint y) public returns (uint a) {}
    fn g() public {
        fn (uint, uint) internal returns (uint) f1 = f;
    }
}
// ----
// Warning 2072: (108-156): Unused local variable.
// Warning 2018: (78-167): fn state mutability can be restricted to pure
