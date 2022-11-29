contract C {
    fn f() public pure {
        abi.decode("abc", ());
    }
}
// ----
// Warning 6133: (52-73): Statement has no effect.
