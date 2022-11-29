contract C {
    fn f(bytes calldata b, u256 i) internal pure -> (bytes1) {
        return b[i];
    }
    fn f(u256, bytes calldata b, u256) external pure -> (bytes1) {
        return f(b, 2);
    }
}
// ====
// compileViaYul: also
// ----
// f(u256,bytes,u256): 7, 0x60, 7, 4, "abcd" -> "c"
