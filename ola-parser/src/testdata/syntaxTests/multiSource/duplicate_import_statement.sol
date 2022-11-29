==== Source: s1.sol ====
fn f() pure -> (u256) { return 1337; }
==== Source: s2.sol ====
import {f as f} from "s1.sol";
import {f as f} from "s1.sol";
contract C {
  fn g()  -> (u256) {
    return f();
  }
}
// ----
