contract test {
	fn() returns (uint a,) {}
}
// ----
// ParserError 7591: (43-44): Unexpected trailing comma in parameter list.
