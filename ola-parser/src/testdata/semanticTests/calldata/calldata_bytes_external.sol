contract CalldataTest {
    fn test(bytes calldata x)  -> (bytes calldata) {
        return x;
    }
    fn tester(bytes calldata x)  -> (bytes1) {
        return this.test(x)[2];
    }
}
// ====
// EVMVersion: >=byzantium
// compileViaYul: also
// ----
// tester(bytes): 0x20, 0x08, "abcdefgh" -> "c"
