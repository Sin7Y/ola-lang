contract C {
    receive() external payable virtual {}
}

contract D is C {
    receive() external payable override {}
}
// ----
// DeclarationError 6899: (59-65): Receive ether fn cannot return values.
