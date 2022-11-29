contract A {
	fn foo() external virtual view ->(u256) { return 5; }
}
contract B is A {
	fn foo() external virtual override view ->(u256) { return 5; }
}
contract C is A {
	fn foo() external virtual override view ->(u256) { return 5; }
}
contract X is B, C {
	u256  override foo;
}
// ----
// TypeError 4327: (305-313):  state variable needs to specify overridden contracts "B" and "C".
