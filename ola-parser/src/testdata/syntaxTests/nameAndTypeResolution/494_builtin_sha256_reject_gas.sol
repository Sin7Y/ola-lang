contract C {
    fn f() public {
        sha256.gas();
    }
}
// ----
// TypeError 9582: (47-57): Member "gas" not found or not visible after argument-dependent lookup in fn (bytes memory) pure returns (bytes32).
