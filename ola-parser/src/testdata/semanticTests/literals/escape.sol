pragma abicoder v2;

contract C
{
	fn f()  -> (u256, bytes1, bytes1) {
		bytes memory encoded = abi.encodePacked("\\\\");
		return (encoded.length, encoded[0], encoded[1]);
	}
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 2, 0x5c00000000000000000000000000000000000000000000000000000000000000, 0x5c00000000000000000000000000000000000000000000000000000000000000
