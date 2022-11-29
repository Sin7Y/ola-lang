pragma abicoder               v2;

contract C {
    fn d() public {
    }
    fn e() public payable returns (uint) {
        return msg.value;
    }
    fn f(uint a) public pure returns (uint, uint) {
        return (a, a);
    }
    fn g() public  pure returns (uint, uint) {
        return (2, 3);
    }
    fn h(uint x, uint y) public  pure returns (uint) {
        unchecked { return x - y; }
    }
    fn i(bool b) public  pure returns (bool) {
        return !b;
    }
    fn j(bytes32 b) public pure returns (bytes32, bytes32) {
        return (b, b);
    }
    fn k() public pure returns (uint) {
        return msg.data.length;
    }
    fn l(uint a) public pure returns (uint d) {
        return a * 7;
    }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// d() ->
// e(), 1 wei -> 1
// e(), 1 ether -> 1000000000000000000
// f(uint256): 3 -> 3, 3
// g() -> 2, 3
// h(uint256,uint256): 1, -2 -> 3
// i(bool): true -> false
// j(bytes32): 0x10001 -> 0x10001, 0x10001
// k(): hex"4200efef" -> 8
// l(uint256): 99 -> 693
