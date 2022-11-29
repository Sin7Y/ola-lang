contract test {
	fn a(uint a, uint b, uint c) returns (uint r) { r = a * 100 + b * 10 + c * 1; }
	fn b() returns (uint r) { r = a({a: , b: , c: }); }
}
// ----
// ParserError 6933: (146-147): Expected primary expression.
