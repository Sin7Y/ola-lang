contract A {
	fn foo() internal -> (u256);
}
contract X {
	fn foo() internal override(X, address) -> (u256);
}
// ----
// ParserError 2314: (109-116): Expected identifier but got 'address'
