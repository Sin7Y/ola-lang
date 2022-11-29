contract C {
    u256  x = msg.value - 10;
    constructor() payable {}
}

contract D {
    fn f()  {
        unchecked {
            new C();
        }
    }
    fn g()  payable -> (u256) {
        return (new C{value: 11}()).x();
    }
}
// ====
// compileViaYul: also
// ----
// f() -> FAILURE, hex"4e487b71", 0x11
// g(), 100 wei -> 1
// gas legacy: 101790
