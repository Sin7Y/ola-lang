contract Base {
	uint public x;
	uint public y;
	fn init(uint a, uint b) public {
		x = a;
		y = b;
	}
	fn init(uint a) public {
		x = a;
	}
}

contract Child is Base {
	fn cInit(uint c) public {
		Base.init(c);
	}
	fn cInit(uint c, uint d) public {
		Base.init(c, d);
	}
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// x() -> 0
// y() -> 0
// cInit(u256): 2 ->
// x() -> 2
// y() -> 0
// cInit(u256,u256): 3, 3 ->
// x() -> 3
// y() -> 3
