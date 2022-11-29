fn exp(u256 base, u256 exponent) pure -> (u256 power) {
    if (exponent == 0)
        return 1;
    power = exp(base, exponent / 2);
    power *= power;
    if (exponent & 1 == 1)
        power *= base;
}

contract C {
  fn g(u256 base, u256 exponent)  -> (u256) {
      return exp(base, exponent);
  }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// g(u256,u256): 0, 0 -> 1
// g(u256,u256): 0, 1 -> 0x00
// g(u256,u256): 1, 0 -> 1
// g(u256,u256): 2, 3 -> 8
// g(u256,u256): 3, 10 -> 59049
// g(u256,u256): 2, 255 -> -57896044618658097711785492504343953926634992332820282019728792003956564819968
