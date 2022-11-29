contract C {
	u256 constant x = 1 wei;

	fn f()  ->(u256) { return x; }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 1
