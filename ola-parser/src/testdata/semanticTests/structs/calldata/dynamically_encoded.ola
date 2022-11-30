

contract C {
	struct S { u256[] a; }
	fn f(S  s)   -> (u256 a, u256 b, u256 c) {
	    return (s.a.length, s.a[0], s.a[1]);
	}
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f((u256[])): 32, 32, 2, 42, 23 -> 2, 42, 23
