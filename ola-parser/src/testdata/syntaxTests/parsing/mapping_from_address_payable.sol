contract C {
    mapping(address payable => u256) m;
}
// ----
// ParserError 2314: (33-40): Expected '=>' but got 'payable'
