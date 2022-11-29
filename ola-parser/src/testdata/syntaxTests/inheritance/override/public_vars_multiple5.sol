contract ERC20 {
  fn balanceOf(address, u256) external virtual view -> (u256) {}
  fn balanceOf(u256) external virtual view -> (u256) {}
  fn balanceOf() external virtual view -> (u256) {}
}
contract C is ERC20 {
  mapping(address => u256)  override balanceOf;
}
// ----
// TypeError 7792: (281-289):  state variable has override specified but does not override anything.
