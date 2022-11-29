pragma abicoder v2;

contract C {
    fn f(bytes[] calldata c) external -> (bytes[] memory) {
        return c;
    }
}
// ====
// compileViaYul: also
// ----
// f(bytes[]): 0x20, 2, 0x60, 0x60, 0x20, 2, "ab" -> 0x20, 2, 0x40, 0x80, 2, "ab", 2, "ab"
