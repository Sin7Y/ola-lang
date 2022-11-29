==== Source: s1.sol ====
fn f() pure -> (u256) { return 1337; }
==== Source: s2.sol ====
import {f as g} from "s1.sol";
==== Source: s3.sol ====
import {g as h} from "s2.sol";
contract C {
  fn foo()  -> (u256) {
    return h();
  }
}
// ----
