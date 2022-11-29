contract C {
    receive() external payable {}
}

contract D is C {
    fallback() external override {}
}
// ----
// TypeError 7792: (76-84): fn has override specified but does not override anything.
