// This tests that the compiler knows the correct size of the fn on the stack.
contract c {
    uint256[] data;

    fn test() public returns (uint256 x) {
        x = 2;
        data.pop;
        x = 3;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// test() -> 3
