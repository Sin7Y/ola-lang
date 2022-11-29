contract A {
	fn f() external virtual {}
}
contract B {
	fn f() external virtual {}
}
contract C is A, B {
	fn f() external override (A, B) {}
}
contract X is C {
}
// ----
