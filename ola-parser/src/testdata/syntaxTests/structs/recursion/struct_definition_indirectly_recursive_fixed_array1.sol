contract Test {
    struct MyStructName1 {
        address addr;
        u256 count;
        MyStructName2[1] x;
    }
    struct MyStructName2 {
        MyStructName1 x;
    }
}
// ----
// TypeError 2046: (20-121): Recursive struct definition.
