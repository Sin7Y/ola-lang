library Test {
    struct MyStructName {
        address addr;
        MyStructName[] x;
    }

    fn f(MyStructName storage s) public {}
}
// ----
