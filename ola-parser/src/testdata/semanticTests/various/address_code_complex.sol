contract A {
    constructor() {
        assembly {
            // This is only 7 bytes here.
            mstore(0, 0x48aa5566000000)
            return(0, 32)
        }
    }
}

contract C {
    fn f()  -> (bytes memory) { return address(new A()).code; }
    fn g()  -> (u256) { return address(new A()).code.length; }
}
// ====
// compileViaYul: also
// ----
// f() -> 0x20, 0x20, 0x48aa5566000000
// g() -> 0x20
