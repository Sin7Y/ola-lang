contract c {
	uint[] a;
	fn f() returns (uint, uint) {
		return ([3, ,4][0]);
	}
}
// ----
// ParserError 4799: (75-76): Expected expression (inline array elements cannot be omitted).
