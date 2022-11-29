contract C {
    struct S {
        u256 a;
        bytes b;
        mapping(u256 => u256) c;
        u256[] d;
    }
    u256 shifter;
    S s;

    constructor() {
        s.a = 7;
        s.b = "abc";
        s.c[0] = 9;
    }
}
// ====
// compileViaYul: also
// ----
// s() -> 0x07, 0x40, 0x03, 0x6162630000000000000000000000000000000000000000000000000000000000
