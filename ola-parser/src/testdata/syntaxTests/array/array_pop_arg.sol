contract C {
    uint[] data;
    fn test() public {
      data.pop(5);
    }
}
// ----
// TypeError 6160: (65-76): Wrong argument count for fn call: 1 arguments given but expected 0.
