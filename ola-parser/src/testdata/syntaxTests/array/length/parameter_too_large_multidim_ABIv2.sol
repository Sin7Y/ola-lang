pragma abicoder               v2;

contract C {
  fn f(bytes32[1263941234127518272][500] memory) public pure {}
  fn f(uint[2**30][2**30][][] memory) public pure {}
}
// ----
// TypeError 1534: (61-101): Type too large for memory.
// TypeError 1534: (131-160): Type too large for memory.
