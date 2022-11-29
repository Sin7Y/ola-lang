contract A {
	fn foo() internal view virtual -> (u256) {}
}
contract B is A {
	fn foo() internal pure override virtual -> (u256) {}
}
contract C is A {
	fn foo() internal view override virtual -> (u256) {}
}
contract D is B, C {
	fn foo() internal pure override(B, C) virtual -> (u256) {}
}
contract E is C, B {
	fn foo() internal pure override(B, C) virtual -> (u256) {}
}
// ----
