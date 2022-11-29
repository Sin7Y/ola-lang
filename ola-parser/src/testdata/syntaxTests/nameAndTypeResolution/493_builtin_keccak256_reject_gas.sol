contract C {
    fn f() public {
        keccak256.gas();
    }
}
// ----
// TypeError 9582: (47-60): Member "gas" not found or not visible after argument-dependent lookup in fn (bytes memory) pure returns (bytes32).
