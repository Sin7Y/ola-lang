contract C {
    fn f() pure public {
        uint a = 1;
    }
}
// ----
// Warning 2072: (52-58): Unused local variable.
