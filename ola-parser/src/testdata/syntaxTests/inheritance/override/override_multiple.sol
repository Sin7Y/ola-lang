abstract contract A {
	fn foo() internal virtual -> (u256);
	fn test(uint8 _a) internal virtual -> (u256) {}
}
abstract contract B {
	fn foo() internal virtual -> (u256);
	fn test() internal virtual -> (u256);
}
abstract contract C {
	fn foo() internal virtual -> (u256);
}
abstract contract D {
	fn foo() internal virtual -> (u256);
}
contract X is A, B, C, D {
	fn test() internal override -> (u256) {}
	fn foo() internal override(A, B, C, D) -> (u256) {}
}
// ----
