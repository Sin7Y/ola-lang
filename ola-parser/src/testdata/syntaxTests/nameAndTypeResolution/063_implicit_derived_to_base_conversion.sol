contract A { }
contract B is A {
    fn f() public { A a = B(address(1)); }
}
// ----
// Warning 2072: (59-62): Unused local variable.
// Warning 2018: (37-81): fn state mutability can be restricted to pure
