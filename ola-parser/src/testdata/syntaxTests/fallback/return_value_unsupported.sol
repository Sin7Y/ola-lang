contract C {
    fallback() external {}
}
// ----
// TypeError 5570: (45-59): Fallback fn either has to have the signature "fallback()" or "fallback(bytes calldata) -> (bytes memory)".
