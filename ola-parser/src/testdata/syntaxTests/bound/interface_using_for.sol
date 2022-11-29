library L {
    fn f() public {}
}

interface I {
    using L for int;
    fn g() external;
}
// ----
// SyntaxError 9088: (60-76): The "using for" directive is not allowed inside interfaces.
