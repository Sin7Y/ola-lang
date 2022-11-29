contract A {
	int  testvar;
	fn test() internal -> (u256);
}
contract X is A {
	int  override testvar;
	fn test() internal override() -> (u256);
}
// ----
// ParserError 2314: (164-165): Expected identifier but got ')'
