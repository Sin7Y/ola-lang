contract TransferTest {
	fallback() external payable {
		// This used to cause an ICE
		payable(this).transfer;
	}

	fn f()   {}
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() ->
