contract A {
	fn foo() external virtual view ->(A) {  }
	fn foo(u256 ) external virtual view ->(u256) { return 4; }
	fn foo(u256 , u256 ) external view virtual ->(A) {  }
}
contract X is A {
	u256  override foo;
}
// ----
// TypeError 4822: (225-249): Overriding  state variable return types differ.
