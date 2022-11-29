contract C { fn foo(D _d)  { _d.foo(this); } }
contract D { fn foo(C _c)  { _c.foo(this); } }
// ----
