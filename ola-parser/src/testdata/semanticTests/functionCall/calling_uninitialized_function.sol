contract C {
    fn intern() public -> (u256) {
        fn (uint) internal -> (uint) x;
        x(2);
        return 7;
    }

    fn extern() public -> (u256) {
        fn (uint) external -> (uint) x;
        x(2);
        return 7;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// intern() -> FAILURE, hex"4e487b71", 0x51 # This should throw exceptions #
// extern() -> FAILURE
