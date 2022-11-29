contract C {
	u256 constant x = 1 gwei;

	fn f()  ->(u256) { return x; }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 1000000000
