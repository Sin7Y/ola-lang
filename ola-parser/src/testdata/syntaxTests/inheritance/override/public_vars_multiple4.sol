contract ERC20 {
  fn balanceOf(address) external virtual view -> (u256) {}
  fn balanceOf(u256) external virtual view -> (u256) {}
  fn balanceOf() external virtual view -> (u256) {}
}
contract C is ERC20 {
  mapping(address => u256)  override balanceOf;
}
// ----
