pragma abicoder v2;
contract C {
  struct S { uint x; uint[] b; }
  fn f() public pure returns (S memory, bytes memory, uint[][2] memory) {
    return abi.decode("abc", (S, bytes, uint[][2]));
  }
}
// ----
