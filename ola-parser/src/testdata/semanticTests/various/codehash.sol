contract C {
    fn f()  -> (bytes32) {
        // non-existent in tests
        return address(0).codehash;
    }
    fn g()  -> (bytes32) {
        // precompile
        return address(0x1).codehash;
    }
    fn h()  -> (bool) {
        return address(this).codehash != 0;
    }
}

// ====
// EVMVersion: >=constantinople
// compileViaYul: also
// ----
// f() -> 0x0
// g() -> 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
// h() -> true
