contract C {
    fn f() public pure -> (uint32 y) {
        uint8 x = uint8(u256(0x31313131313131313131313131313131));
        assembly { y := x }
    }

    fn g() public pure -> (bytes32 y) {
        bytes1 x = bytes1(bytes16(0x31313131313131313131313131313131));
        assembly { y := x }
    }

    fn h() external -> (bytes32 y) {
        bytes1 x;
        assembly { x := sub(0,1) }
        y = x;
    }
}
// ====
// compileViaYul: true
// ----
// f() -> 0x31
// g() -> 0x3100000000000000000000000000000000000000000000000000000000000000
// h() -> 0xff00000000000000000000000000000000000000000000000000000000000000
