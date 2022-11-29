contract BaseBase {
	fn f(uint n) public virtual -> (uint) {
		return 2 * n;
	}
	fn s(uint n) public -> (uint) {
		return 4 * n;
	}
}

contract Base is BaseBase {
	fn f(uint n) public virtual override -> (uint) {
		return 3 * n;
	}
}

contract Child is Base {
	fn g(uint n) public -> (uint) {
		return f(n);
	}

	fn h(uint n) public -> (uint) {
		return s(n);
	}
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// g(u256): 4 -> 12
// h(u256): 4 -> 16
