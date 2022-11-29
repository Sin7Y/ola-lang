contract C {
    fallback() external payable { }
    fn f()  { }
}
// ----
// Warning 3628: (0-83): This contract has a payable fallback fn, but no receive ether fn. Consider adding a receive ether fn.
