contract test {
    fn foo() public {
    }

    fn f() public {
        foo g;
    }
}
// ----
// TypeError 5172: (85-88): Name has to refer to a struct, enum or contract.
