type MyInt8 is int8;
contract C {
    MyInt8  x = MyInt8.wrap(-5);

    /// The most significant bit is flipped to 0
    fn create_dirty_slot() external {
        u256 mask  = 2**255 -1;
        assembly {
            let value := sload(x.slot)
            sstore(x.slot, and(mask, value))
        }
    }

    fn read_unclean_value() external -> (bytes32 ret) {
        MyInt8 value = x;
        assembly {
            ret := value
        }
    }
}
// ====
// compileViaYul: also
// ----
// x() -> -5
// create_dirty_slot() ->
// read_unclean_value() -> 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb
