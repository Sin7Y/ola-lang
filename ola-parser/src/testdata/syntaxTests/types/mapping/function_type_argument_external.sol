contract C {
    fn f(fn(mapping(uint=>uint) storage) external) public pure {
    }
}
// ----
// TypeError 6651: (37-64): Data location must be "memory" or "calldata" for parameter in fn, but "storage" was given.
