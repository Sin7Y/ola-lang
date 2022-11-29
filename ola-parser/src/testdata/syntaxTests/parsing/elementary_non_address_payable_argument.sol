contract C {
    fn a(bool payable) public pure {}
    fn b(string payable) public pure {}
    fn c(int payable) public pure {}
    fn d(int256 payable) public pure {}
    fn e(uint payable) public pure {}
    fn f(uint256 payable) public pure {}
    fn g(bytes1 payable) public pure {}
    fn h(bytes payable) public pure {}
    fn i(bytes32 payable) public pure {}
    fn j(fixed payable) public pure {}
    fn k(fixed80x80 payable) public pure {}
    fn l(ufixed payable) public pure {}
    fn m(ufixed80x80 payable) public pure {}
}
// ----
// ParserError 9106: (33-40): State mutability can only be specified for address types.
// ParserError 9106: (79-86): State mutability can only be specified for address types.
// ParserError 9106: (122-129): State mutability can only be specified for address types.
// ParserError 9106: (168-175): State mutability can only be specified for address types.
// ParserError 9106: (212-219): State mutability can only be specified for address types.
// ParserError 9106: (259-266): State mutability can only be specified for address types.
// ParserError 9106: (305-312): State mutability can only be specified for address types.
// ParserError 9106: (350-357): State mutability can only be specified for address types.
// ParserError 9106: (397-404): State mutability can only be specified for address types.
// ParserError 9106: (442-449): State mutability can only be specified for address types.
// ParserError 9106: (492-499): State mutability can only be specified for address types.
// ParserError 9106: (538-545): State mutability can only be specified for address types.
// ParserError 9106: (589-596): State mutability can only be specified for address types.
