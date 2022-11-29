contract A {
	fn foo() external virtual view ->(u256) { return 5; }
}
contract B is A {
	u256  override foo;
}
contract C is A {
	fn foo() external virtual override view ->(u256) { return 5; }
}
contract X is B, C {
	u256  override foo;
}
// ----
// DeclarationError 9097: (245-269): Identifier already declared.
// TypeError 1452: (100-124): Cannot override  state variable.
// TypeError 4327: (257-265):  state variable needs to specify overridden contracts "B" and "C".
