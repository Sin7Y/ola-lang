contract A {
	fn foo() internal -> (u256);
}
contract X {
	fn test() internal override(,) -> (u256);
}
// ----
// ParserError 2314: (107-108): Expected identifier but got ','
