contract C {
    fn fallback() external pure {}
}
// ----
// Warning 3445: (26-34): This fn is named "fallback" but is not the fallback fn of the contract. If you intend this to be a fallback fn, use "fallback(...) { ... }" without the "fn" keyword to define it.
