contract C {
  fn f() public view {
    address payable a = this;
    a;
  }
  fallback() external payable {
  }
}
// ----
// Warning 3628: (0-120): This contract has a payable fallback fn, but no receive ether fn. Consider adding a receive ether fn.
// TypeError 9574: (46-70): Type contract C is not implicitly convertible to expected type address payable.
