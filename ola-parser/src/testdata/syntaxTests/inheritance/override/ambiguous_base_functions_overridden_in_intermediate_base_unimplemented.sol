contract A {
	fn f() external virtual {}
}
contract B {
	fn f() external virtual {}
}
contract C is A, B {
	fn f() external override (A, B);
}
contract X is C {
}
// ----
// TypeError 4593: (120-158): Overriding an implemented fn with an unimplemented fn is not allowed.
// TypeError 4593: (120-158): Overriding an implemented fn with an unimplemented fn is not allowed.
// TypeError 5424: (120-158): Functions without implementation must be marked virtual.
