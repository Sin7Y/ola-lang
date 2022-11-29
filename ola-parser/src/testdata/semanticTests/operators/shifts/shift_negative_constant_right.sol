contract C {
    int256 a = -0x4200 >> 8;
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// a() -> -66
