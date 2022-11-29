library D { struct s { uint a; } fn mul(s storage self, uint x) public -> (uint) { return self.a *= x; } }
contract C {
    using D for D.s;
    D.s public x;
    fn f(uint a) public -> (uint) {
        x.a = 6;
        return (x.mul)({x: a});
    }
}
// ====
// compileToEwasm: false
// compileViaYul: also
// ----
// library: D
// f(u256): 7 -> 0x2a
// x() -> 0x2a
