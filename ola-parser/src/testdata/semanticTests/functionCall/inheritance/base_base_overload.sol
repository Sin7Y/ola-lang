contract BaseBase {
	uint public x;
	uint public y;
	fn init(uint a, uint b) public virtual {
		x = b;
		y = a;
	}
	fn init(uint a) public virtual {
		x = a + 1;
	}
}

contract Base is BaseBase {
	fn init(uint a, uint b) public override {
		x = a;
		y = b;
	}
	fn init(uint a) public override {
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
	fn bInit(uint c) public {
		BaseBase.init(c);
	}
	fn bInit(uint c, uint d) public {
		BaseBase.init(c, d);
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
// bInit(u256): 4 ->
// x() -> 5
// bInit(u256,u256): 9, 10 ->
// x() -> 10
// y() -> 9
