contract D {
    fallback() external {}
}

contract E {
    fallback() external {}
}

contract F {
    fallback() external {}
}
// ----
// TypeError 5570: (57-71): Fallback fn either has to have the signature "fallback()" or "fallback(bytes calldata) -> (bytes memory)".
// TypeError 5570: (134-150): Fallback fn either has to have the signature "fallback()" or "fallback(bytes calldata) -> (bytes memory)".
// TypeError 5570: (215-231): Fallback fn either has to have the signature "fallback()" or "fallback(bytes calldata) -> (bytes memory)".
