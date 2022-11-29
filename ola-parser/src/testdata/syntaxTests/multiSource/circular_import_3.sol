==== Source: s1.sol ====
import {f as g, g as h} from "s2.sol";
fn f() pure -> (u256) { return h() - g(); }
==== Source: s2.sol ====
import {f as h} from "s1.sol";
fn f() pure -> (u256) { return 2; }
fn g() pure -> (u256) { return 4; }
==== Source: s3.sol ====
import "s1.sol";
import "s2.sol";
// ----
// DeclarationError 1686: (s1.sol:39-93): fn with same name and parameter types defined twice.
// DeclarationError 1686: (s2.sol:31-77): fn with same name and parameter types defined twice.
// DeclarationError 1686: (s2.sol:78-124): fn with same name and parameter types defined twice.
