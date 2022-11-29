contract C {
    bytes s = "abcdefghabcdefgh";
    bytes sLong = "abcdefghabcdefghabcdefghabcdefgh";

    fn fromMemory(bytes memory m)  -> (bytes16) {
        return bytes16(m);
    }
    fn fromCalldata(bytes calldata c) external -> (bytes16) {
        return bytes16(c);
    }
    fn fromStorage() external -> (bytes16) {
        return bytes16(s);
    }
    fn fromStorageLong() external -> (bytes32) {
        return bytes32(sLong);
    }
    fn fromSlice(bytes calldata c) external -> (bytes8) {
        return bytes8(c[1:9]);
    }
}
// ====
// compileViaYul: also
// ----
// fromMemory(bytes): 0x20, 16, "abcdefghabcdefgh" -> "abcdefghabcdefgh"
// fromCalldata(bytes): 0x20, 16, "abcdefghabcdefgh" -> "abcdefghabcdefgh"
// fromStorage() -> "abcdefghabcdefgh"
// fromStorageLong() -> "abcdefghabcdefghabcdefghabcdefgh"
// fromSlice(bytes): 0x20, 16, "abcdefghabcdefgh" -> "bcdefgha"
