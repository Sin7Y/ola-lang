contract C {
    fn() internal returns (uint)[20] x;
    int256 mutex;

    fn one() public returns (uint256) {
        fn() internal returns (uint)[20] memory xmem;
        x = xmem;
        return 3;
    }

    fn two() public returns (uint256) {
        if (mutex > 0) return 7;
        mutex = 1;
        // If this test fails, it might re-execute this fn.
        x[0]();
        return 2;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// one() -> 3
// gas legacy: 140260
// gas legacyOptimized: 140097
// two() -> FAILURE, hex"4e487b71", 0x51
