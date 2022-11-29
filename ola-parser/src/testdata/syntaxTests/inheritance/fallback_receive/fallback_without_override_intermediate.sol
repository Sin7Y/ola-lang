contract C {
    fallback() external virtual {}
}

contract D is C {}

contract E is D {
    fallback() external {}
}
// ----
// TypeError 9456: (86-108): Overriding fn is missing "override" specifier.
