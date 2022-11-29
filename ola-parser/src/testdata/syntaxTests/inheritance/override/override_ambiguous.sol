abstract contract A {
	fn foo() internal virtual -> (u256);
}
abstract contract B {
	fn foo() internal virtual -> (u256);
	fn test() internal virtual -> (u256);
}
abstract contract X is A, B {
	fn test() internal override -> (u256) {}
}
// ----
// TypeError 6480: (205-292): Derived contract must override fn "foo". Two or more base classes define fn with same name and parameter types.
