contract C {
    receive() external payable virtual {}
}

contract D is C {}

contract E is D {
    receive() external payable {}
}
// ----
// TypeError 9456: (93-122): Overriding fn is missing "override" specifier.
