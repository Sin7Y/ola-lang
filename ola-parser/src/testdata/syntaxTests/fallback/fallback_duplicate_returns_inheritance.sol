contract C {
    fallback() external {}
}

contract D is C {
    fallback() external {}
}
// ----
// TypeError 9456: (116-138): Overriding fn is missing "override" specifier.
// TypeError 4334: (17-91): Trying to override non-virtual fn. Did you forget to add "virtual"?
