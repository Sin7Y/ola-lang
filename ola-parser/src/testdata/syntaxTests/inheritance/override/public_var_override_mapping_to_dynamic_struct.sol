pragma abicoder               v2;

abstract contract C {
	struct S {
	u256 x;
	string y;
	}
	fn f(address x) external virtual -> (u256, string memory);
}
contract D is C {
	mapping(address => S)  override f;
}
// ----
