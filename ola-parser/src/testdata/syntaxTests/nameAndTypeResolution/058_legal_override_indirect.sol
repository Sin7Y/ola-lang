contract A { fn f(uint a) public {} }
contract B { fn f() public {} }
contract C is A, B { }
// ----
