contract A is B { }
contract B { fn f() public { new C(); } }
contract C { fn f() public { new A(); } }
// ----
// TypeError 2449: (14-15): Definition of base has to precede definition of derived contract
