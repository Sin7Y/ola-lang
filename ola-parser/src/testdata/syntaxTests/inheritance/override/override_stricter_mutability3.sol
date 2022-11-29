contract A {
	fn foo() internal view virtual -> (u256) {}
}
contract B is A {
	fn foo() internal pure override virtual -> (u256) {}
}
// ----
