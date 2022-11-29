contract C {
  fn f() public view {
    address payable a = payable(this);
    a;
  }
  fallback() external payable {
  }
}
// ----
// Warning 3628: (0-129): This contract has a payable fallback fn, but no receive ether fn. Consider adding a receive ether fn.
