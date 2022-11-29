contract C {
    fn() external {}
}
// ----
// ParserError 2915: (37-38): Expected a state variable declaration. If you intended this as a fallback fn or a fn to handle plain ether transactions, use the "fallback" keyword or the "receive" keyword instead.
