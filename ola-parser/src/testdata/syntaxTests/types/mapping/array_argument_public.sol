contract C {
    fn f(mapping(uint => uint)[] storage) public pure {
    }
}
// ----
// TypeError 6651: (28-59): Data location must be "memory" or "calldata" for parameter in fn, but "storage" was given.
