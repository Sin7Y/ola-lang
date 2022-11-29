contract C {
    // Check that visibility is also enforced for the receive ether fn.
    receive() external {}
}
// ----
// SyntaxError 4937: (95-107): No visibility specified. Did you intend to add "external"?
// DeclarationError 7793: (95-107): Receive ether fn must be payable, but is "nonpayable".
// DeclarationError 4095: (95-107): Receive ether fn must be defined as "external".
