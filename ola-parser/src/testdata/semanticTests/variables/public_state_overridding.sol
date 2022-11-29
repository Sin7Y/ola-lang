contract A
{
	fn test() external virtual -> (u256)
	{
		return 5;
	}
}
contract X is A
{
	u256 public override test;

	fn set() public { test = 2; }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// test() -> 0
// set() ->
// test() -> 2
