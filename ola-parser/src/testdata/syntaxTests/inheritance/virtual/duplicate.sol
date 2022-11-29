contract C
{
	fn foo() virtual  virtual {}
	modifier modi() virtual virtual {_;}
}
// ----
// ParserError 6879: (44-51): Virtual already specified.
// ParserError 2662: (80-87): Virtual already specified.
