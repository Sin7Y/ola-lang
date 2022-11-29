contract A {
	fn foo() internal virtual -> (u256) {}
}
contract B is A {
	fn foo() internal view override virtual -> (u256) {}
}
// ----
