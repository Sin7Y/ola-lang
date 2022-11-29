contract C {
    fn f(fn() external returns (mapping(uint=>uint) storage)) public pure {
    }
}
// ----
// TypeError 6651: (57-84): Data location must be "memory" or "calldata" for return parameter in fn, but "storage" was given.
