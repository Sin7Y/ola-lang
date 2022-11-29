contract C {
    string data;
    fn test() public {
      data.pop();
    }
}
// ----
// TypeError 9582: (65-73): Member "pop" not found or not visible after argument-dependent lookup in string storage ref.
