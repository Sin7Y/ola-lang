abstract contract A {
	int  testvar;
	fn foo() internal virtual -> (u256);
	fn test(uint8 _a) internal virtual -> (u256);
}
abstract contract B {
	fn foo() internal virtual -> (u256);
}

abstract contract C is A {
}
abstract contract D is A, B, C {
	fn foo() internal override(A, B) virtual -> (u256);
}
// ----
