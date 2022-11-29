contract C {
  fn f() public pure returns (C c) {
    address a = address(2);
    c = C(a);
  }
  fallback() external payable {
  }
}
// ----
// Warning 3628: (0-139): This contract has a payable fallback fn, but no receive ether fn. Consider adding a receive ether fn.
// TypeError 7398: (92-96): Explicit type conversion not allowed from non-payable "address" to "contract C", which has a payable fallback fn.
