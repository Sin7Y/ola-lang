contract C { fn foo() internal { new D(); } }
contract D { fn foo() internal { new C(); } }
// ----
