contract C {
    error E();
    u256 x = 2;
    fn f()  {
        revert E();
        x = 4;
    }
}
// ----
// Warning 5740: (98-103): Unreachable code.
