contract C {
    fn f(bytes calldata c)  -> (string calldata s) {
        return string(c);
    }
}
// ====
// compileViaYul: also
// ----
// f(bytes): 0x20, 3, "abc" -> 0x20, 3, "abc"
