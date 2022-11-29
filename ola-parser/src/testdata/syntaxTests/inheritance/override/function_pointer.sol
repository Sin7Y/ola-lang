contract C {
	fn() external virtual fp;
	fn() external override fp2;
	fn() external override virtual fp3;
}
// ----
// ParserError 2314: (34-41): Expected identifier but got 'virtual'
