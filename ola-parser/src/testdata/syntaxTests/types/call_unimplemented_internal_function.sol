abstract contract A {
    fn f() public virtual;
    fn g() public {
        f();
    }
}
// ----
