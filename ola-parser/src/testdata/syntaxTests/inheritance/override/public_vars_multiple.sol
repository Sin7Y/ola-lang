contract A {
	fn foo() external virtual view ->(u256) { return 5; }
}
contract B {
	fn foo() external virtual view ->(u256) { return 5; }
}
contract X is A, B {
	u256  override foo;
}
// ----
// TypeError 4327: (196-204):  state variable needs to specify overridden contracts "A" and "B".
