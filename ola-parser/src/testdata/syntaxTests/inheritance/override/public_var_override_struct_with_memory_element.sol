pragma abicoder               v2;

abstract contract C {
	struct S {
		u256 x;
		string y;
	}

	fn f() external virtual -> (u256, string memory);
}
contract D is C {
	S  override f;
}
// ----
