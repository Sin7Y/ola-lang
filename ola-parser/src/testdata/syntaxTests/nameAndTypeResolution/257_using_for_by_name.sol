library D { struct s { uint a; } fn mul(s storage self, uint x) public returns (uint) { return self.a *= x; } }
contract C {
    using D for D.s;
    D.s x;
    fn f(uint a) public returns (uint) {
        return x.mul({x: a});
    }
}
// ----
