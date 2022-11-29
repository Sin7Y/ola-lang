contract A { fn f() public virtual { uint8 x = C(address(0)).g(); } }
contract B { fn f() public virtual {} fn g() public returns (uint8) {} }
contract C is A, B { fn f() public override (A, B) { A.f(); } }
// ----
// Warning 2072: (43-50): Unused local variable.
