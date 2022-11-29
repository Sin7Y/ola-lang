contract C {
    u256[8**90] ids;
    u256[2**256 - 1] okay;
    u256[2**256] tooLarge;
}
// ----
// TypeError 1847: (22-27): Array length too large, maximum is 2**256 - 1.
// TypeError 1847: (68-74): Array length too large, maximum is 2**256 - 1.
