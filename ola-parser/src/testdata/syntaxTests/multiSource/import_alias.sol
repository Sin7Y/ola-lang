==== Source: s1.sol ====
int constant a = 2;
==== Source: s2.sol ====
import {a as e} from "s1.sol";
import "s2.sol" as M;
contract C {
  fn f()  -> (int) { return M.e; }
}
// ----
