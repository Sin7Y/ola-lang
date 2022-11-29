contract C {
    constructor() payable {}

    fn f()  -> (u256 ret) {
        assembly {
            ret := balance(0)
        }
    }
    fn g()  -> (u256 ret) {
        assembly {
            ret := balance(1)
        }
    }
    fn h()  -> (u256 ret) {
        assembly {
            ret := balance(address())
        }
    }
}

// ====
// EVMVersion: >=constantinople
// compileViaYul: also
// ----
// constructor(), 23 wei ->
// gas legacy: 100517
// f() -> 0
// g() -> 1
// h() -> 23
