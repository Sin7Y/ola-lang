contract Test {
    fn bytesToBytes(bytes4 input) public returns (bytes4 ret) {
        return bytes4(input);
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// bytesToBytes(bytes4): "abcd" -> "abcd"
