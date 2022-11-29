contract C {
    enum X { A, B }
    event Log(X);

    fn test_log()  -> (u256) {
        X garbled = X.A;
        assembly {
            garbled := 5
        }
        emit Log(garbled);
        return 1;
    }
    fn test_log_ok()  -> (u256) {
        X x = X.A;
        emit Log(x);
        return 1;
    }
}
// ====
// compileViaYul: also
// ----
// test_log_ok() -> 1
// ~ emit Log(uint8): 0x00
// test_log() -> FAILURE, hex"4e487b71", 0x21
