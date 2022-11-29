==== Source: s1.sol ====
fn f() pure -> (uint16) { return 1337; }
fn g() pure -> (uint8) { return 42; }
==== Source: s2.sol ====
import {f as g} from "s1.sol";
==== Source: s3.sol ====
// imports f(uint16)->1337 as g(uint16)
import "s2.sol";
// imports f(uint16)->1337 as f(uint16) and
// g(uint8)->42 as g(uint8)
import {f as f, g as g} from "s1.sol";
contract C {
  fn foo()  -> (u256) {
    // calls f()->1337 / f()->1337
    return f() / g();
  }
}
// ----
// DeclarationError 1686: (s1.sol:0-51): fn with same name and parameter types defined twice.
