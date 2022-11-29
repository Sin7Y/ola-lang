contract test {
    struct test_struct {
        address addr;
        mapping(uint64 => mapping(bytes32 => u256)) complex_mapping;
    }
}
// ----
