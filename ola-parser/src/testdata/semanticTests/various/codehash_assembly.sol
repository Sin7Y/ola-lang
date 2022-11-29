contract C {
    fn f()  -> (bytes32 ret) {
        assembly {
            ret := extcodehash(0)
        }
    }
    fn g()  -> (bytes32 ret) {
        assembly {
            ret := extcodehash(1)
        }
    }
    fn h()  -> (bool ret) {
        assembly {
            ret := iszero(iszero(extcodehash(address())))
        }
    }
}

// ====
// EVMVersion: >=constantinople
// compileViaYul: also
// ----
// f() -> 0
// g() -> 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
// h() -> true
