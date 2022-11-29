pragma abicoder v2;

contract C {
    fn g(bytes[2] memory m) internal -> (bytes memory) {
        return m[0];
    }
    fn f(bytes[2] calldata c) external -> (bytes memory) {
        return g(c);
    }
}
// ====
// compileViaYul: also
// ----
// f(bytes[2]): 0x20, 0x40, 0x40, 2, "ab" -> 0x20, 2, "ab"
