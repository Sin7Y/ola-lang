contract test {
    struct test_struct {
        address addr;
        u256 count;
        mapping(bytes32 => test_struct) self_reference;
    }
}
// ----
