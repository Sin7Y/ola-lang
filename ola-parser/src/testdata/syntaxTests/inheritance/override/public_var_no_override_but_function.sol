contract A {
	fn foo() internal virtual view ->(u256) { return 5; }
}
contract X is A {
	u256  foo;
}
// ----
// TypeError 9456: (100-115): Overriding  state variable is missing "override" specifier.
// TypeError 5225: (100-115):  state variables can only override functions with external visibility.
