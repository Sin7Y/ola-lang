contract Test {
    string s;
    bytes b;

    fn f(string memory _s, u256 n)  -> (bytes1) {
        b = bytes(_s);
        s = string(b);
        return bytes(s)[n];
    }

    fn l()  -> (u256) {
        return bytes(s).length;
    }
}
// ====
// compileViaYul: also
// ----
// f(string,u256): 0x40, 0x02, 0x06, "abcdef" -> "c"
// l() -> 0x06
