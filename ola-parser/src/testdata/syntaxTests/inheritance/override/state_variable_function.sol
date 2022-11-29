contract A {
	u256  x;
}
contract C is A {
	fn x()  -> (u256) {}
}
// ----
// DeclarationError 9097: (50-87): Identifier already declared.
// TypeError 9456: (50-87): Overriding fn is missing "override" specifier.
// TypeError 1452: (14-27): Cannot override  state variable.
