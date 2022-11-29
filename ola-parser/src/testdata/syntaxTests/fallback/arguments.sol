contract C {
    fallback() external {}
}
// ----
// TypeError 5570: (44-44): Fallback fn either has to have the signature "fallback()" or "fallback(bytes calldata) -> (bytes memory)".
