contract C {
    fn f() public pure returns (mapping(uint=>uint) storage m) {
    }
}
// ----
// TypeError 6651: (51-80): Data location must be "memory" or "calldata" for return parameter in fn, but "storage" was given.
