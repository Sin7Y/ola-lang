contract C {
	u256 constant x = 1 ether;

	fn f()  ->(u256) { return x; }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 1000000000000000000
