==== Source: s1.sol ====
contract C
{
	fn normal()  -> (u256) { return 1337; }
	fn reverting()  -> (u256) { revert(); }
}
==== Source: s2.sol ====
import "s1.sol";
contract D is C
{
	fn foo()  -> (u256) { normal(); }
	fn bar()  -> (u256) { reverting(); }
}
// ----
// Warning 6321: (s2.sol:72-76): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
