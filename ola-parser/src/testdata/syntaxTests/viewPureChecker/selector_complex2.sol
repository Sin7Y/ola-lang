contract C {
        fn f() payable  -> (C) {
        return this;
    }
    fn g()   -> (bytes4) {
        C x = C(address(0x123));
        return x.f.selector;
    }
}
// ----
