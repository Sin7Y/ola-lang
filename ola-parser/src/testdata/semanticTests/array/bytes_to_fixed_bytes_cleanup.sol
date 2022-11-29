contract C {
    bytes s = "abcdefghabcdefghabcdefghabcdefg";

    fn fromMemory(bytes memory m)  -> (bytes16) {
        assembly { mstore(m, 14) }
        return bytes16(m);
    }
    fn fromCalldata(bytes calldata c) external -> (bytes16) {
        return bytes16(c);
    }
    fn fromStorage() external -> (bytes32) {
        return bytes32(s);
    }
    fn fromSlice(bytes calldata c) external -> (bytes8) {
        return bytes8(c[0:6]);
    }
}
// ====
// compileViaYul: true
// ----
// fromMemory(bytes): 0x20, 16, "abcdefghabcdefgh" -> "abcdefghabcdef\0\0"
// fromCalldata(bytes): 0x20, 15, "abcdefghabcdefgh" -> "abcdefghabcdefg\0"
// fromStorage() -> "abcdefghabcdefghabcdefghabcdefg\0"
// fromSlice(bytes): 0x20, 15, "abcdefghabcdefgh" -> "abcdef\0\0"
