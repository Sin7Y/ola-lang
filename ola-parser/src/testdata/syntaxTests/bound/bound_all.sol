library L {
	fn g(fn() internal returns (uint) _t) internal returns (uint) { return _t(); }
}
contract C {
	using L for *;
	fn f() public returns (uint) {
		return t.g();
	}
	fn t() public pure returns (uint)  { return 7; }
}
// ----
