contract C {
    fn f() external pure returns (mapping(uint=>uint) storage m) {
    }
}
// ----
// TypeError 6651: (53-82): Data location must be "memory" or "calldata" for return parameter in fn, but "storage" was given.
