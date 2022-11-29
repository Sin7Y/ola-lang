contract C {
    fallback() external virtual {}
}

contract D is C {
    fallback() external {}
}
// ----
// TypeError 9456: (66-88): Overriding fn is missing "override" specifier.
