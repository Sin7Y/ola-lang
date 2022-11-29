contract A {
	fn foo(u256) internal virtual pure ->(u256) { return 5; }
}
contract X is A {
	u256  foo;
}
// ----
