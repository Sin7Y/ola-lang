==== Source: s1.sol ====
fn f() pure -> (u256) { return 1337; }
==== Source: s2.sol ====
import "s1.sol";
contract C {
  fn g()  -> (u256) {
    return f();
  }
}
// ----
