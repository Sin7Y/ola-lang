==== Source: s1.sol ====
fn f(u256) pure -> (u256) { return 24; }
fn g() pure -> (bool) { return true; }
==== Source: s2.sol ====
import {f as g, g as g} from "s1.sol";
contract C {
  fn foo()  -> (u256, bool) {
    return (g(2), g());
  }
}
// ----
