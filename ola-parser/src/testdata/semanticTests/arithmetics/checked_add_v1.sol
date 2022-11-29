contract C {
    // Input is still not checked - this needs ABIEncoderV2!
    fn f(u32 a, u32 b)  -> (u32) {
        return a + b;
    }
}
// ====
// ABIEncoderV1Only: true
// ----
// f(u32,u32): 65534, 0 -> 0xfffe
// f(u32,u32): 65536, 0 -> 0x00
// f(u32,u32): 65535, 0 -> 0xffff
// f(u32,u32): 65535, 1 -> FAILURE, hex"4e487b71", 0x11
