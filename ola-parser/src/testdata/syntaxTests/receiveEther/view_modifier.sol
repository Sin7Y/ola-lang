contract C {
    uint256 x;

    receive() external view {
        x = 2;
    }
}
// ----
// DeclarationError 7793: (29-63): Receive ether fn must be payable, but is "view".
