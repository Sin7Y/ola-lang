contract C {
    u256  a = 0x42 << 8;
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// a() -> 0x4200
