interface Identity {
    fn selectorAndAppendValue(u256 value) external pure -> (u256);
}
interface ReturnMoreData {
    fn f(u256 value) external pure -> (u256, u256, u256);
}
contract C {
    Identity constant i = Identity(address(0x0004));
    fn testHighLevel() external pure -> (bool) {
        // Works because the extcodesize check is skipped
        // and the precompiled contract -> actual data.
        i.selectorAndAppendValue(5);
        return true;
    }
    fn testHighLevel2() external pure -> (u256, u256, u256) {
        // Fails because the identity contract does not return enough data.
        return ReturnMoreData(address(4)).f(2);
    }
    fn testLowLevel() external view -> (u256 value) {
        (bool success, bytes memory ret) =
            address(4).staticcall(
                abi.encodeWithSelector(Identity.selectorAndAppendValue.selector, u256(5))
            );
        value = abi.decode(ret, (u256));
    }

}
// ====
// EVMVersion: >=constantinople
// compileViaYul: also
// ----
// testHighLevel() -> true
// testLowLevel() -> 0xc76596d400000000000000000000000000000000000000000000000000000000
// testHighLevel2() -> FAILURE
