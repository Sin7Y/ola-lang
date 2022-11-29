contract test {
    u256 a = 2.2e10;
    u256 b = .5E10;
    u256 c = 4.e - 2;
}
// ----
// TypeError 9582: (70-73): Member "e" not found or not visible after argument-dependent lookup in int_const 4.
