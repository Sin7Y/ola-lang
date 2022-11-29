contract C {
    uint16  result_in_constructor;
    fn(uint16) -> (uint16) internal x;
    uint16  other = 0x1fff;

    constructor() {
        x = doubleInv;
        result_in_constructor = use(2);
    }

    fn doubleInv(uint16 _arg)  -> (uint16 _ret) {
        _ret = ~(_arg * 2);
    }

    fn use(uint16 _arg)  -> (uint16) {
        return x(_arg);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// use(uint16): 3 -> 0xfff9
// result_in_constructor() -> 0xfffb
// other() -> 0x1fff
