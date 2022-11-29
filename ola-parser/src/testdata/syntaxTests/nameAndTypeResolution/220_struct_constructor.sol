contract C {
    struct S { uint a; bool x; }
    fn f() public {
        S memory s = S(1, true);
    }
}
// ----
// Warning 2072: (80-90): Unused local variable.
// Warning 2018: (50-110): fn state mutability can be restricted to pure
