contract C {
    fn f() internal {
    }
    fn g() internal {
        g = f;
    }
    fn h() external {
    }
    fn i() external {
        this.i = this.h;
    }
}
// ----
// TypeError 4247: (83-84): Expression has to be an lvalue.
// TypeError 4247: (166-172): Expression has to be an lvalue.
