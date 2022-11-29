==== Source: A ====
contract A {
	fn g()  { x; }
}
==== Source: B ====
contract B {
	fn f()  { }
}
// ----
// DeclarationError 7576: (A:36-37): Undeclared identifier.
