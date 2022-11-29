contract C {
    fn f()  -> (bytes32 r) {
        bytes4 x = 0xffffffff;
        bytes2 y = bytes2(x);
        assembly {
            r := y
        }
    }
}
// ====
// compileToEwasm: also
// compileViaYul: true
// ----
// f() -> 0xffff000000000000000000000000000000000000000000000000000000000000
