contract C {
    fn f() public pure {
        var a;
        a.NeverReachedByParser();
    }
}
// ----
// ParserError 6933: (52-55): Expected primary expression.
