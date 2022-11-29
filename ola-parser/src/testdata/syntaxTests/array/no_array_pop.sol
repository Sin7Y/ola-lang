contract C {
    uint data;
    fn test() public {
      data.pop();
    }
}
// ----
// TypeError 9582: (63-71): Member "pop" not found or not visible after argument-dependent lookup in uint256.
