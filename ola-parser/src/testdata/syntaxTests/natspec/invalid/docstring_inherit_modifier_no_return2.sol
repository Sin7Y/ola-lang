contract A {
	/// @return a
	fn g(int x)  virtual { return 2; }
}

contract B is A {
	fn g(int x)  override -> (int b) { return 2; }
}
// ----
// DocstringParsingError 2604: (14-27): Documentation tag "@return a" exceeds the number of return parameters.
// TypeError 4822: (98-166): Overriding fn return types differ.
// TypeError 8863: (64-72): Different number of arguments in return statement than in -> declaration.
