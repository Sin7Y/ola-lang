contract C {
    fn g(string calldata _s) public {}
    fn h(bytes calldata _b) public {}

    fn f() public {
        g("hello");
        g(unicode"hello");
        h(hex"68656c6c6f");
    }
}
// ----
// TypeError 9553: (139-146): Invalid type for argument in fn call. Invalid implicit conversion from literal_string "hello" to string calldata requested.
// TypeError 9553: (159-173): Invalid type for argument in fn call. Invalid implicit conversion from literal_string "hello" to string calldata requested.
// TypeError 9553: (186-201): Invalid type for argument in fn call. Invalid implicit conversion from literal_string "hello" to bytes calldata requested.
