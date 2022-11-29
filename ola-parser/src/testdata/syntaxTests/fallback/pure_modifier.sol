contract C {
    u256 x;

    fallback() external pure {
        x = 2;
    }
}
// ----
// TypeError 4575: (29-64): Fallback fn must be payable or non-payable, but is "pure".
