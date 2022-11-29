contract C {
	struct S { uint a; uint b; }
	fn f() pure public {
		S memory x;
		S memory y;
		(x, y) = (y, x);
	}
}
// ----
