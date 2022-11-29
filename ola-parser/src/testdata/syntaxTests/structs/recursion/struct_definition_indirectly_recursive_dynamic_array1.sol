contract Test {
    struct MyStructName1 {
        address addr;
        u256 count;
        MyStructName2[] x;
    }
    struct MyStructName2 {
        MyStructName1 x;
    }
}
// ----
