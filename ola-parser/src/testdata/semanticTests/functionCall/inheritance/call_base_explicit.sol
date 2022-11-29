contract Base {
	fn f(uint n) public -> (uint) {
		return 2 * n;
	}
}

contract Child is Base {
	fn g(uint n) public -> (uint) {
		return Base.f(n);
	}
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// g(u256): 4 -> 8
