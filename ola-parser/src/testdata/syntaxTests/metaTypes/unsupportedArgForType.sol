contract Test {
    struct S { u256 x; }
    fn f()  {
        // Unsupported for now, but might be supported in the future
        type(S);
    }
}
// ----
// TypeError 4259: (154-155): Invalid type for argument in the fn call. An enum type, contract type or an integer type is required, but type(struct Test.S) provided.
