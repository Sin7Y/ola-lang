abstract contract A {
	fn foo() internal virtual -> (u256);
}
abstract contract B {
	fn foo() internal virtual -> (uint8);
	fn test() internal virtual -> (u256);
}
abstract contract X is A, B {
	fn test() internal override virtual -> (u256);
}
// ----
// TypeError 6480: (203-296): Derived contract must override fn "foo". Two or more base classes define fn with same name and parameter types.
