contract Test {
    fn set(uint24[3][4] memory x)  {
        x[2][2] = 1;
        x[3][2] = 7;
    }

    fn f()  -> (uint24[3][4] memory) {
        uint24[3][4] memory data;
        set(data);
        return data;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x07
