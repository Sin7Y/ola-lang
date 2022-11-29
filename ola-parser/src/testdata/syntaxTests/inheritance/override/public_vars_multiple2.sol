contract A {
	fn foo() external virtual view ->(u256) { return 4; }
	fn foo(u256 ) external virtual view ->(u256) { return 4; }
	fn foo(u256 , u256 ) external view virtual ->(A) {  }
}
contract X is A {
	u256  override foo;
}
// ----
