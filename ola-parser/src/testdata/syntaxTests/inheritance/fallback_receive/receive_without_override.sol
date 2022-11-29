contract C {
    receive() external payable virtual {}
}

contract D is C {
    receive() external payable {}
}
// ----
// TypeError 9456: (73-102): Overriding fn is missing "override" specifier.
