interface I {
    receive() external payable;
}

interface J is I {
    receive() external payable override;
}

contract C is J {
    receive() external payable override {}
}
// ----
// DeclarationError 6857: (25-33): Receive ether fn cannot take parameters.
