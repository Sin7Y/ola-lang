contract C {
	fn f(bytes calldata x) public pure returns (C[] memory c) {
		c = abi.decode(x, (C[]));
	}
}
// ----
