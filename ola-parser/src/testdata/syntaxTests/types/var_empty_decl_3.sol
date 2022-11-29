contract C {
    fn f() public pure {
        var (d, e,);
    }
}
// ----
// ParserError 6933: (52-55): Expected primary expression.
