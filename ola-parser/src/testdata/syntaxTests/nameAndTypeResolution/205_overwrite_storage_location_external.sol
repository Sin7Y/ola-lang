contract C {
    fn f(uint[] storage a) external {}
}
// ----
// TypeError 6651: (28-44): Data location must be "memory" or "calldata" for parameter in external fn, but "storage" was given.
