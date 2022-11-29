contract C {
    uint256 x;

    receive() external pure {
        x = 2;
    }
}
// ----
// DeclarationError 7793: (29-63): Receive ether fn must be payable, but is "pure".
