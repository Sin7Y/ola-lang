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
		// calling base-bse fn of a virtual overridden fn.
		return BaseBase.f(n);
	}

	fn k(uint n) public -> (uint) {
		// Calling base-base fn of a non-virtual fn.
		return BaseBase.s(n);
	}
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// g(u256): 4 -> 8
// k(u256): 4 -> 16
