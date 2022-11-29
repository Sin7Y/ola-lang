type MyUInt16 is uint16;
type MyBytes2 is bytes2;
contract C {
    MyUInt16  a = MyUInt16.wrap(13);
    MyBytes2  b = MyBytes2.wrap(bytes2(uint16(1025)));
    bytes2  x;
    fn write_a() external {
        u256 max = 0xf00e0bbc0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0e0c0ba098076054032001;
        assembly {
            sstore(a.slot, max)
        }
    }
    fn write_b() external {
        u256 max = 0xf00e0bbc0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0e0c0ba098076054032001;
        assembly {
            sstore(b.slot, max)
        }
    }
    fn get_b(u256 index)  -> (bytes1) {
        return MyBytes2.unwrap(b)[index];
    }
}
// ====
// compileViaYul: also
// ----
// a() -> 13
// b() -> 0x0401000000000000000000000000000000000000000000000000000000000000
// get_b(u256): 0 -> 0x0400000000000000000000000000000000000000000000000000000000000000
// get_b(u256): 1 -> 0x0100000000000000000000000000000000000000000000000000000000000000
// get_b(u256): 2 -> FAILURE, hex"4e487b71", 0x32
// write_a() ->
// a() -> 0x2001
// write_b() ->
// b() -> 0x5403000000000000000000000000000000000000000000000000000000000000
// get_b(u256): 0 -> 0x5400000000000000000000000000000000000000000000000000000000000000
// get_b(u256): 1 -> 0x0300000000000000000000000000000000000000000000000000000000000000
// get_b(u256): 2 -> FAILURE, hex"4e487b71", 0x32
