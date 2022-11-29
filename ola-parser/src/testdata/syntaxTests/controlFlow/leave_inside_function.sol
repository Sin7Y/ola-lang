contract C {
    fn f() public pure {
        assembly {
            fn f() {
                // Make sure this doesn't trigger the unimplemented assertion in the control flow builder.
                leave
            }
        }
    }
}
// ----
