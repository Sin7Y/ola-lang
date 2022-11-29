abstract contract A {
	fn foo() internal virtual -> (u256);
	fn test(uint8 _a) internal virtual -> (u256);
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
	fn test() internal virtual -> (u256);
}
abstract contract X is A, B, C, D {
	fn test() internal override(B, D, D) virtual -> (u256);
	fn foo() internal override(A, C, B, B, B, D ,D) virtual -> (u256);
}
// ----
// TypeError 4520: (548-549): Duplicate contract "D" found in override list of "test".
// TypeError 4520: (621-622): Duplicate contract "B" found in override list of "foo".
// TypeError 4520: (624-625): Duplicate contract "B" found in override list of "foo".
// TypeError 4520: (630-631): Duplicate contract "D" found in override list of "foo".
