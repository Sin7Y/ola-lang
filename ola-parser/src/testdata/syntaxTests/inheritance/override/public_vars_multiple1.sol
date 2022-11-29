contract A {
	u256  foo;
}
contract B {
	fn foo() external virtual view ->(u256) { return 5; }
}
contract X is A, B {
	u256  override foo;
}
// ----
// DeclarationError 9097: (136-160): Identifier already declared.
// TypeError 1452: (14-29): Cannot override  state variable.
// TypeError 4327: (148-156):  state variable needs to specify overridden contracts "A" and "B".
