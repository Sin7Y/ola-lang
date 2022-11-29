contract test {
    fn f() public {
        fn() returns(fn() returns(fn() returns(fn() returns(uint)))) x;
        uint y;
        y = x()()()();
    }
}
// ----
