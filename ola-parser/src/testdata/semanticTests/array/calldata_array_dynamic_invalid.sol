


contract C {
    fn f(u256[][]  a) u32 -> (u256) {
        return 42;
    }

    fn g(u256[][]  a) u32 -> (u256) {
        a[0];
        return 42;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256[][]): 0x20, 0x0 -> 42 # valid access stub #
// f(u256[][]): 0x20, 0x1 -> FAILURE # invalid on argument decoding #
// f(u256[][]): 0x20, 0x1, 0x20 -> 42 # invalid on outer access #
// g(u256[][]): 0x20, 0x1, 0x20 -> FAILURE
// f(u256[][]): 0x20, 0x1, 0x20, 0x2, 0x42 -> 42 # invalid on inner access #
// g(u256[][]): 0x20, 0x1, 0x20, 0x2, 0x42 -> FAILURE
