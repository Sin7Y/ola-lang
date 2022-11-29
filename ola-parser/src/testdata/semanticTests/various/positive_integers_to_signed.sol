contract test {
    int8 x = 2;
    int8 y = 127;
    int16 q = 250;
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// x() -> 2
// y() -> 127
// q() -> 250
