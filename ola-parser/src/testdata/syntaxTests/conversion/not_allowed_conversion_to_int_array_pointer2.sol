contract C {
	uint[] a;
	uint[] b;
	fn f() public view {
		uint[] storage c = a;
		uint[] memory d = b;
		d = uint[](c);
	}
}
// ----
