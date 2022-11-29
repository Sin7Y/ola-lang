contract C {
    fallback() external {}
}

contract D {
    fallback() external {}
}
// ----
// TypeError 5570: (45-67): Fallback fn either has to have the signature "fallback()" or "fallback(bytes calldata) -> (bytes memory)".
// TypeError 5570: (131-131): Fallback fn either has to have the signature "fallback()" or "fallback(bytes calldata) -> (bytes memory)".
