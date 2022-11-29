contract C {
    uint private internal a;
    fn f() private external {}
}
// ----
// ParserError 4110: (30-38): Visibility already specified as "private".
// ParserError 9439: (67-75): Visibility already specified as "private".
