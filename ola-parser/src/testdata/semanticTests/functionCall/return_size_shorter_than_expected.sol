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

        LongReturn(address(shortReturn)).f();

        u256 freeMemoryAfter;

        assembly {
            freeMemoryAfter := mload(0x40)
        }

        return freeMemoryAfter - freeMemoryBefore;
    }
}
// ====
// EVMVersion: <=homestead
// compileViaYul: true
// ----
// test() -> 0x0500
// gas legacy: 131966
