contract Test {
    struct MyStructName1 {
        address addr;
        u256 count;
        mapping(u256 => MyStructName1) x;
    }
}
// ----
