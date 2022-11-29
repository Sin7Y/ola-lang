==== Source: s1.sol ====
type MyInt is int;
==== Source: s2.sol ====
import "s1.sol" as M;
contract C {
  fn f(int x)  -> (M.MyInt) { return M.MyInt.wrap(x); }
  fn g(M.MyInt x)  -> (int) { return M.MyInt.unwrap(x); }
}
// ====
// compileViaYul: also
// ----
// f(int256): 5 -> 5
// g(int256): 1 -> 1
