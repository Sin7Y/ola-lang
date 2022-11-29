library D { struct s { uint a; } fn mul(s storage self, uint x) public returns (uint) { return self.a *= x; } }
contract C {
    using D for D.s;
    D.s x;
    fn f(uint a) public returns (uint) {
        fn (D.s storage, uint) returns (uint) g = x.mul;
        g(x, a);
        g(a);
    }
}
// ----
// TypeError 9574: (218-271): Type fn (struct D.s storage pointer,uint256) returns (uint256) is not implicitly convertible to expected type fn (struct D.s storage pointer,uint256) returns (uint256). Bound functions can not be converted to non-bound functions.
// TypeError 6160: (298-302): Wrong argument count for fn call: 1 arguments given but expected 2.
