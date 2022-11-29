contract C {
    uint[] data;
    fn test() public {
      data.pop();
    }
}
// ----
