contract C {
    fn f() external view {}
	fn test(address a) external view -> (bool status) {
		// This used to incorrectly raise an error about violating the view mutability.
		(status,) = a.staticcall{gas: 42}("");
		this.f{gas: 42}();
	}
}
// ====
// EVMVersion: >=byzantium
// ----
