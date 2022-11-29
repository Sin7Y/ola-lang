contract C {
	fn f(address a) external view -> (bool success) {
		(success,) = a.call{gas: 42}("");
	}
	fn h() external payable {}
	fn i() external view {
		this.h{gas: 42}();
	}
}
// ----
// TypeError 8961: (90-109): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (180-197): fn cannot be declared as view because this expression (potentially) modifies the state.
