interface LongReturn {
    fn f() external pure -> (u256[20] memory);
}
contract ShortReturn {
    fn f() external pure -> (bytes32) {}
}

contract Test {
    fn test()  -> (u256) {
        ShortReturn shortReturn = new ShortReturn();
        u256 freeMemoryBefore;
        assembly {
            freeMemoryBefore := mload(0x40)
        }

        // This reverts. The external call succeeds but ABI decoding fails due to the returned
        // `bytes32` being much shorter than the expected `u256[20]`.
        LongReturn(address(shortReturn)).f();

        u256 freeMemoryAfter;

        assembly {
            freeMemoryAfter := mload(0x40)
        }

        return freeMemoryAfter - freeMemoryBefore;
    }
}
// ====
// EVMVersion: >homestead
// compileViaYul: true
// ----
// test() -> FAILURE
// gas legacy: 131966
