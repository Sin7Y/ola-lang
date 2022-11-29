abstract contract B {
    fn f() public virtual;
}
contract C is B {
    fn f() public override {
        B.f();
    }
}
// ----
// TypeError 7501: (118-123): Cannot call unimplemented base fn.
