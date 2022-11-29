contract C {
	fn f(address a) external view -> (bool success) {
		(success,) = a.call{value: 42}("");
	}
	fn h() external payable {}
	fn i() external view {
		this.h{value: 42}();
	}
}
// ----
// TypeError 8961: (90-111): fn cannot be declared as view because this expression (potentially) modifies the state.
// TypeError 8961: (182-201): fn cannot be declared as view because this expression (potentially) modifies the state.
