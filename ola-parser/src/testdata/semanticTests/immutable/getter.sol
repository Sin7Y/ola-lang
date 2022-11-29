contract C {
    u256 immutable x = 1;
}
// ====
// compileViaYul: also
// ----
// x() -> 1
