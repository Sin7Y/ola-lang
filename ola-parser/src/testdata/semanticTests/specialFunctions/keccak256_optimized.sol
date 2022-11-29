// tests compile-time evaluation of keccak256 on literal strings
contract C {
    fn short()  -> (bool) {
        bytes32 a = keccak256("abcdefghijklmn");
        bytes memory s = "abcdefghijklmn";
        return a == keccak256(s);
    }
    bytes32 constant sc = keccak256("abcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmn");
    fn long()  -> (bool, bool) {
        bytes32 a = keccak256("abcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmn");
        bytes memory s = "abcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmnabcdefghijklmn";
        return (a == keccak256(s), sc == keccak256(s));
    }
}
// ====
// compileViaYul: also
// ----
// short() -> true
// long() -> true, true
