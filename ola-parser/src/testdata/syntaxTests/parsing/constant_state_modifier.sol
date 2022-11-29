contract C {
	uint s;
	fn f() public constant returns (uint) {
		return s;
	}
}
// ----
// ParserError 2314: (43-51): Expected '{' but got 'constant'
