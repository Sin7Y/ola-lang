contract C {
    fn f() external payable {}
	fn g(address a) external pure {
		a.call{value: 42};
		a.call{gas: 42};
		a.staticcall{gas: 42};
		a.delegatecall{gas: 42};
	}
	fn h() external view {
		this.f{value: 42};
		this.f{gas: 42};
	}
}
// ----
