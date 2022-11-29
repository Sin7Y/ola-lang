contract C {
	u256 constant x = 1 ether + 1 gwei + 1 wei;

	fn f()  ->(u256) { return x; }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 1000000001000000001
