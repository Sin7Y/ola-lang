contract C {
    fn receive() external pure {}
}
// ----
// Warning 3445: (26-33): This fn is named "receive" but is not the receive fn of the contract. If you intend this to be a receive fn, use "receive(...) { ... }" without the "fn" keyword to define it.
