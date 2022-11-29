contract C {
    fn f(uint x) pure public {
        if (x > 7)
            revert("abc");
        else
            revert();
    }
}
// ----
