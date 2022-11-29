contract C {
    fn f() pure public {
        for (uint x = 0; true; x++)
        {}
    }
}
// ----
