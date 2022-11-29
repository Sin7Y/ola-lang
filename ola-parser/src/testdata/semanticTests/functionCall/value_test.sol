contract C {
	fn f()  payable -> (u256) {
		return msg.value;
	}
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f(), 1 ether -> 1000000000000000000
// f(), 1 wei -> 1
