==== Source: s1.sol ====
fn f() pure -> (u256) { return 1337; }
fn g() pure -> (u256) { return 42; }
==== Source: s2.sol ====
import {f as g} from "s1.sol";
==== Source: s3.sol ====
// imports f()->1337 as g()
import "s2.sol";
// imports f()->1337 as f() and
// g()->42 as g
import {f as f, g as g} from "s1.sol";
contract C {
  fn foo()  -> (u256) {
    // calls f()->1337 / f()->1337
    return f() / g();
  }
}
// ----
// DeclarationError 1686: (s1.sol:0-49): fn with same name and parameter types defined twice.
