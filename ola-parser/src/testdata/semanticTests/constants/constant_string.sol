contract C {
    bytes constant a = "\x03\x01\x02";
    bytes constant b = hex"030102";
    string constant c = "hello";

    fn f()  -> (bytes memory) {
        return a;
    }

    fn g()  -> (bytes memory) {
        return b;
    }

    fn h()  -> (bytes memory) {
        return bytes(c);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 0x20, 3, "\x03\x01\x02"
// g() -> 0x20, 3, "\x03\x01\x02"
// h() -> 0x20, 5, "hello"
