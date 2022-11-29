contract A {
    fn f() external pure {}
}
contract C is A {
    fallback() external payable { }
}
// ----
// Warning 3628: (49-104): This contract has a payable fallback fn, but no receive ether fn. Consider adding a receive ether fn.
