contract C {
	fn f() pure public {
		(uint a, uint b, uint c) = g();
		(uint d) = 2;
		(, uint e) = (3,4);
		(uint h,) = (4,5);
		(uint x,,) = g();
		(, uint y,) = g();
        a; b; c; d; e; h; x; y;
	}
	fn g() pure public returns (uint, uint, uint) {}
}
// ----
