contract C {
    fn f() public {
        delete f;
    }
}
// ----
// TypeError 4247: (54-55): Expression has to be an lvalue.
