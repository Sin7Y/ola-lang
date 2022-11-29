contract C {
	fn f() public payable {
		fn() external payable x = this.f{value: 7};
	}
}
// ----
// TypeError 9574: (46-94): Type fn () payable external is not implicitly convertible to expected type fn () payable external.
