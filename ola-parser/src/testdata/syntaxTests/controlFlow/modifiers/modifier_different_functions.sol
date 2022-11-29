contract A {
	fn f() mod internal returns (uint[] storage) {
		revert();
	}
	fn g() mod internal returns (uint[] storage) {
	}
	modifier mod() virtual {
		_;
	}
}
// ----
// TypeError 3464: (118-132): This variable is of storage pointer type and can be returned without prior assignment, which would lead to undefined behaviour.
