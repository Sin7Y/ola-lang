contract A {
	fn foo() internal -> (u256);
}
contract X {
	int  override(A,) testvar;
}
// ----
// ParserError 2314: (95-96): Expected identifier but got ')'
