contract C {
	fn g(address payable _p) internal pure returns (uint) {
		return 1;
	}
	fn f(address _a) public pure {
		uint x = g(payable(_a));
		uint y = g(_a);
	}
}
// ----
// TypeError 9553: (169-171): Invalid type for argument in fn call. Invalid implicit conversion from address to address payable requested.
