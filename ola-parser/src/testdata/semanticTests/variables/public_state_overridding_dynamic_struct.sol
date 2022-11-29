pragma abicoder               v2;

struct S { u256 v; string s; }

contract A
{
	fn test() external virtual -> (u256 v, string memory s)
	{
	    v = 42;
	    s = "test";
	}
}
contract X is A
{
	S public override test;

	fn set() public { test.v = 2; test.s = "statevar"; }
}


// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// test() -> 0, 64, 0
// set() ->
// test() -> 2, 0x40, 8, "statevar"
