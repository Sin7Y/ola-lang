contract c1 {
    fn f() payable payable {}
}
contract c2 {
    fn f() view view {}
}
contract c3 {
    fn f() pure pure {}
}
contract c4 {
    fn f() pure view {}
}
contract c5 {
    fn f() payable view {}
}
contract c6 {
    fn f() pure payable {}
}
contract c7 {
    fn f() view payable {}
}
// ----
// ParserError 9680: (39-46): State mutability already specified as "payable".
// ParserError 9680: (88-92): State mutability already specified as "view".
// ParserError 9680: (134-138): State mutability already specified as "pure".
// ParserError 9680: (180-184): State mutability already specified as "pure".
// ParserError 9680: (229-233): State mutability already specified as "payable".
// ParserError 9680: (275-282): State mutability already specified as "pure".
// ParserError 9680: (324-331): State mutability already specified as "view".
