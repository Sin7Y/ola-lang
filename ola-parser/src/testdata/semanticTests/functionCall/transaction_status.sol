contract test {
	fn f()  { }
	fn g()  { revert(); }
	fn h()  { assert(false); }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() ->
// g() -> FAILURE
// h() -> FAILURE, hex"4e487b71", 0x01
