
contract C {
	struct S2 { u256 b; }
	struct S { u256 a; S2[] children; }
	fn f(S  s)   -> (u256, u256, u256, u256) {
		return (s.children.length, s.a, s.children[0].b, s.children[1].b);
	}
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f((u256,(u256)[])): 32, 17, 64, 2, 23, 42 -> 2, 17, 23, 42
