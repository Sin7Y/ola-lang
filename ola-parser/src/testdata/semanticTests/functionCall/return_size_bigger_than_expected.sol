interface ShortReturn {
    fn f() external pure -> (bytes32);
}
contract LongReturn {
    fn f() external pure -> (u256[20] memory) {}
}

contract Test {
    fn test()  -> (u256) {
        LongReturn longReturn = new LongReturn();
        u256 freeMemoryBefore;
        assembly {
            freeMemoryBefore := mload(0x40)
        }

        ShortReturn(address(longReturn)).f();

        u256 freeMemoryAfter;

        assembly {
            freeMemoryAfter := mload(0x40)
        }

        return freeMemoryAfter - freeMemoryBefore;
    }
}
// ====
// compileViaYul: true
// ----
// test() -> 0x20
// gas legacy: 131966
