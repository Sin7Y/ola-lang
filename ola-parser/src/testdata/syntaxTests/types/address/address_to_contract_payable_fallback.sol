contract C {
  fn f() public pure returns (C c) {
    c = C(payable(address(2)));
  }
  fallback() external payable {
  }
}
// ----
// Warning 3628: (0-129): This contract has a payable fallback fn, but no receive ether fn. Consider adding a receive ether fn.
