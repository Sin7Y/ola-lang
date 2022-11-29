contract X {
	int  override override testvar;
	fn test() internal override override -> (u256);
}
// ----
// ParserError 9125: (34-42): Override already specified.
// ParserError 1827: (87-95): Override already specified.
