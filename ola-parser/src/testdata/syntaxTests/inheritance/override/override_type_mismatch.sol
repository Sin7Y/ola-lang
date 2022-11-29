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
}
abstract contract X is A, B, C, D {
	struct MyStruct { int abc; }
	enum ENUM { F,G,H }

	fn test() internal override virtual -> (u256);
	fn foo() internal override(MyStruct, ENUM, A, B, C, D) virtual -> (u256);
}
// ----
// TypeError 9301: (602-610): Expected contract but got struct X.MyStruct.
// TypeError 9301: (612-616): Expected contract but got enum X.ENUM.
