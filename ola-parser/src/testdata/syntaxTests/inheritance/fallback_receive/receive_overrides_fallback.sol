contract C {
    fallback() external {}
}

contract D is C {
    receive() external payable override {}
}
// ----
// TypeError 7792: (68-76): fn has override specified but does not override anything.
