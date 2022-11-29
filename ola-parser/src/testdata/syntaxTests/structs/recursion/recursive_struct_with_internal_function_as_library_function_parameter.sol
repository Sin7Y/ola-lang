library Test {
    struct MyStructName {
        address addr;
        MyStructName[] x;
        fn() internal y;
    }

    fn f(MyStructName storage s) public {}
}
// ----
// TypeError 4103: (142-164): Internal type is not allowed for public or external functions.
