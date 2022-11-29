contract C {
    u256 value;

    fn set(u256 _value) external {
        value = _value;
    }

    fn get() external view -> (u256) {
        return value;
    }

    fn get_delegated() external -> (bool, bytes memory) {
        return address(this).delegatecall(abi.encodeWithSignature("get()"));
    }

    fn assert0() external view {
        assert(value == 0);
    }

    fn assert0_delegated() external -> (bool, bytes memory) {
        return address(this).delegatecall(abi.encodeWithSignature("assert0()"));
    }
}
// ====
// EVMVersion: >=byzantium
// compileViaYul: also
// ----
// get() -> 0x00
// assert0_delegated() -> 0x01, 0x40, 0x0
// get_delegated() -> 0x01, 0x40, 0x20, 0x0
// set(u256): 0x01 ->
// get() -> 0x01
// assert0_delegated() -> 0x00, 0x40, 0x24, 0x4e487b7100000000000000000000000000000000000000000000000000000000, 0x0100000000000000000000000000000000000000000000000000000000
// get_delegated() -> 0x01, 0x40, 0x20, 0x1
// set(u256): 0x2a ->
// get() -> 0x2a
// assert0_delegated() -> 0x00, 0x40, 0x24, 0x4e487b7100000000000000000000000000000000000000000000000000000000, 0x0100000000000000000000000000000000000000000000000000000000
// get_delegated() -> 0x01, 0x40, 0x20, 0x2a
