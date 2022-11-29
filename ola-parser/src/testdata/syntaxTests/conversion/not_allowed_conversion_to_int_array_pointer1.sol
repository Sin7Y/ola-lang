contract C {
	uint[] a;
	uint[] b;
	fn f() public view {
		uint[] storage c = a;
		uint[] storage d = b;
		d = uint[](c);
	}
}
// ----
