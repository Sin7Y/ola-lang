contract C {
	fn() internal view returns(uint256) immutable z;
	constructor() {
		z = f;
	}
	fn f() public view returns (uint256) {
		return 7;
	}
	fn callZ() public view returns (uint) {
		return z();
	}
}
// ====
// compileViaYul: also
// ----
// f() -> 7
// callZ() -> 7
