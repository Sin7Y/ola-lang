contract C {
    fn f() public {
        bytes memory a;
        bytes memory b = type(bytes).concat(a);
    }
}
// ----
// TypeError 4259: (93-98): Invalid type for argument in the fn call. An enum type, contract type or an integer type is required, but type(bytes) provided.
