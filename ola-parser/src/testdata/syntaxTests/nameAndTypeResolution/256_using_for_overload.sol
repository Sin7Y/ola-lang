library D {
    struct s { uint a; }
    fn mul(s storage self, uint x) public returns (uint) { return self.a *= x; }
    fn mul(s storage, bytes32) public returns (bytes32) { }
}
contract C {
    using D for D.s;
    D.s x;
    fn f(uint a) public returns (uint) {
        return x.mul(a);
    }
}
// ----
