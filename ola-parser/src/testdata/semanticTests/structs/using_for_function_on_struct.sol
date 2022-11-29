library D { struct s { uint a; } fn mul(s storage self, uint x) public -> (uint) { return self.a *= x; } }
contract C {
    using D for D.s;
    D.s public x;
    fn f(uint a) public -> (uint) {
        x.a = 3;
        return x.mul(a);
    }
}
// ====
// compileToEwasm: false
// compileViaYul: also
// ----
// library: D
// f(u256): 7 -> 0x15
// x() -> 0x15
