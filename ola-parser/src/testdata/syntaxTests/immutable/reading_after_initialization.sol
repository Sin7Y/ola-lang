contract C {
    uint immutable x = 0;
    uint y = 0;

    fn f() internal {
        y = x + 1;
    }
}
// ----
