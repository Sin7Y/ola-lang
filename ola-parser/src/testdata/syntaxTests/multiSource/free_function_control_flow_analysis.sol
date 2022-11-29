==== Source: s1.sol ====
fn normal() pure -> (u256) { return 1337; }
fn reverting() pure -> (u256) { revert(); }
==== Source: s2.sol ====
import "s1.sol";
contract C
{
	fn foo()  -> (u256) { normal(); }
	fn bar()  -> (u256) { reverting(); }
}
// ----
// Warning 6321: (s2.sol:67-71): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
