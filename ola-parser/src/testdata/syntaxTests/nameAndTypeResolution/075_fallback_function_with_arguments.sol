contract C {
    uint256 x;

    fallback() external {
        x = 2;
    }
}
// ----
// TypeError 5570: (55-55): Fallback fn either has to have the signature "fallback()" or "fallback(bytes calldata) returns (bytes memory)".
