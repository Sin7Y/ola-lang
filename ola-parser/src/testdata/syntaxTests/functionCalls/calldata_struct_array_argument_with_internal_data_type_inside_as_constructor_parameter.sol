contract C {
	struct S {
		fn() a;
	}
	constructor (S[2] storage) public {}
}
// ----
// TypeError 3644: (58-70): This parameter has a type that can only be used internally. You can make the contract abstract to avoid this problem.
