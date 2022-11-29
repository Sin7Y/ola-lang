contract C {
    receive() external payable {}
}
// ----
// DeclarationError 6857: (24-33): Receive ether fn cannot take parameters.
