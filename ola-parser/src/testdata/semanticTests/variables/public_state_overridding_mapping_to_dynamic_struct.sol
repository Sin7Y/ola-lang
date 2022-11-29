pragma abicoder               v2;

struct S { u256 v; string s; }

contract A
{
	fn test(u256 x) external virtual -> (u256 v, string memory s)
	{
	    v = x;
	    s = "test";
	}
}
contract X is A
{
	mapping(u256 => S) public override test;

	fn set() public { test[42].v = 2; test[42].s = "statevar"; }
}


// ====
// compileViaYul: also
// ----
// test(u256): 0 -> 0, 64, 0
// test(u256): 42 -> 0, 64, 0
// set() ->
// test(u256): 0 -> 0, 64, 0
// test(u256): 42 -> 2, 0x40, 8, "statevar"
