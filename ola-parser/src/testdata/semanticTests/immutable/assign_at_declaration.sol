contract A {
	uint8 immutable a = 2;
	fn f() public view returns (uint) {
		return a;
	}
}
// ====
// compileViaYul: also
// ----
// f() -> 2
