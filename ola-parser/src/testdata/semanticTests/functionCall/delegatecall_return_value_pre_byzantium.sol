contract C {
    u256 value;

    fn set(u256 _value) external {
        value = _value;
    }

    fn get() external view -> (u256) {
        return value;
    }

    fn get_delegated() external -> (bool) {
        (bool success,) = address(this).delegatecall(abi.encodeWithSignature("get()"));
        return success;
    }

    fn assert0() external view {
        assert(value == 0);
    }

    fn assert0_delegated() external -> (bool) {
        (bool success,) = address(this).delegatecall(abi.encodeWithSignature("assert0()"));
        return success;
    }
}
// ====
// compileViaYul: also
// EVMVersion: <byzantium
// ----
// get() -> 0x00
// assert0_delegated() -> true
// get_delegated() -> true
// set(u256): 0x01 ->
// get() -> 0x01
// assert0_delegated() -> false
// get_delegated() -> true
// set(u256): 0x2a ->
// get() -> 0x2a
// assert0_delegated() -> false
// get_delegated() -> true
