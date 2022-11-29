contract C {
    receive() external {}
}
// ----
// DeclarationError 7793: (17-56): Receive ether fn must be payable, but is "nonpayable".
// DeclarationError 6899: (44-53): Receive ether fn cannot return values.
