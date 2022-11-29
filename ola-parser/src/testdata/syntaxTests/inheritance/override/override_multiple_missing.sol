abstract contract A {
	fn foo() internal virtual -> (u256);
	fn test(uint8 _a) virtual internal -> (u256);
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
	fn test() internal override(B, D, C) virtual -> (u256);
	fn foo() internal override(A, C) virtual -> (u256);
}
// ----
// TypeError 2353: (533-550): Invalid contract specified in override list: "C".
// TypeError 4327: (603-617): fn needs to specify overridden contracts "B" and "D".
