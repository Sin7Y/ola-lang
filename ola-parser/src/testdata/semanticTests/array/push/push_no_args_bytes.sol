contract C {
	bytes array;

	fn f() public {
		array.push();
	}

	fn g(uint x) public {
		for (uint i = 0; i < x; ++i)
			array.push() = bytes1(uint8(i));
	}

	fn l() public returns (uint) {
		return array.length;
	}

	fn a(uint index) public view returns (bytes1) {
		return array[index];
	}
}
// ====
// compileViaYul: also
// ----
// l() -> 0
// g(uint256): 70 ->
// gas irOptimized: 185922
// gas legacy: 183811
// gas legacyOptimized: 179218
// l() -> 70
// a(uint256): 69 -> left(69)
// f() ->
// l() -> 71
// a(uint256): 70 -> 0
