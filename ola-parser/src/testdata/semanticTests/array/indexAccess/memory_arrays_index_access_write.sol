contract Test {
    fn set(u32[3][4]  x)  {
        x[2][2] = 1;
        x[3][2] = 7;
    }

    fn f()  -> (u32[3][4] ) {
        u32[3][4]  data;
        set(data);
        return data;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x07
