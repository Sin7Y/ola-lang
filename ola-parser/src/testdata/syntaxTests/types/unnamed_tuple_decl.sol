contract C {
    fn f() internal pure {}
    fn g() internal pure returns (uint) { return 1; }
    fn h() internal pure returns (uint, uint) { return (1, 2); }

    fn test() internal pure {
        () = f();
        () = g();
        (,) = h();
    }
}

// ----
// ParserError 6933: (224-225): Expected primary expression.
