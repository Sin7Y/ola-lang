==== Source: s1.sol ====
import {f as g} from "s2.sol";
fn f() pure -> (u256) { return 1; }
==== Source: s2.sol ====
import {f as g} from "s1.sol";
fn f() pure -> (u256) { return 2; }
// ----
