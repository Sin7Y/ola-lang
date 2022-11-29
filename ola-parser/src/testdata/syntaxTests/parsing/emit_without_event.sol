contract C {
	event A();
	fn f() {
		emit A;
	}
}
// ----
// ParserError 2314: (49-50): Expected '(' but got ';'
