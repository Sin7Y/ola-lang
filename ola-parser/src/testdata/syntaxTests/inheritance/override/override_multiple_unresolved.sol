contract A {
	int  testvar;
	fn foo() internal override(N, Z) -> (u256);
}
// ----
// DeclarationError 7920: (68-69): Identifier not found or not unique.
