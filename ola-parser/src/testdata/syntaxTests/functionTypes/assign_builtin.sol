contract C {
  fn f() public {
     fn (uint) view returns (bytes32) _blockhash = blockhash;
  }
}
// ----
// TypeError 9574: (42-103): Type fn (uint256) view returns (bytes32) is not implicitly convertible to expected type fn (uint256) view returns (bytes32). Special functions can not be converted to fn types.
