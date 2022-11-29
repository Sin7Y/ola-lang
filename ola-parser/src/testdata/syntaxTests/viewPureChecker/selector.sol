contract C {
    u256  x;
    fn f() payable  {
    }
    fn g()   -> (bytes4) {
        return this.f.selector ^ this.x.selector;
    }
    fn h() view  -> (bytes4) {
        x;
        return this.f.selector ^ this.x.selector;
    }
}
// ----
