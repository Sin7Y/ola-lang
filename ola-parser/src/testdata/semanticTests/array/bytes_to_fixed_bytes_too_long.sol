contract C {
    bytes s = "abcdefghabcdefghabcdefghabcdefgha";

    fn fromMemory(bytes memory m)  -> (bytes32) {
        return bytes32(m);
    }
    fn fromCalldata(bytes calldata c) external -> (bytes32) {
        return bytes32(c);
    }
    fn fromStorage() external -> (bytes32) {
        return bytes32(s);
    }
    fn fromSlice(bytes calldata c) external -> (bytes32) {
        return bytes32(c[0:33]);
    }
}
// ====
// compileViaYul: also
// ----
// fromMemory(bytes): 0x20, 33, "abcdefghabcdefghabcdefghabcdefgh", "a" -> "abcdefghabcdefghabcdefghabcdefgh"
// fromCalldata(bytes): 0x20, 33, "abcdefghabcdefghabcdefghabcdefgh", "a" -> "abcdefghabcdefghabcdefghabcdefgh"
// fromStorage() -> "abcdefghabcdefghabcdefghabcdefgh"
// fromSlice(bytes): 0x20, 33, "abcdefghabcdefghabcdefghabcdefgh", "a" -> "abcdefghabcdefghabcdefghabcdefgh"
