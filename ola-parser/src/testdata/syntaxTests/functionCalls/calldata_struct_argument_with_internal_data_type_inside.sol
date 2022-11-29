contract C {
	struct S {
		fn() a;
	}
	fn f(S calldata) public {}
}
// ----
// TypeError 4103: (56-66): Internal type is not allowed for public or external functions.