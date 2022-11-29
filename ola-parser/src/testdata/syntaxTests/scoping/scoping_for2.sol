contract test {
    fn f() pure public {
        for (uint x = 0; x < 10; x ++)
            x = 2;
    }
}
// ----
