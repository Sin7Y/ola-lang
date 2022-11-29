contract C {
    fn f()  -> (string memory, u256) {
        return ("abc", 8);
    }

    fn g()  -> (string memory, string memory) {
        return (h(), "def");
    }

    fn h()  -> (string memory) {
        return ("abc");
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 0x40, 0x8, 0x3, "abc"
// g() -> 0x40, 0x80, 0x3, "abc", 0x3, "def"
