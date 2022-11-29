==== Source: s1.sol ====
library L
{
	fn normal()  -> (u256) { return 1337; }
	fn reverting()  -> (u256) { revert(); }
}
==== Source: s2.sol ====
import "s1.sol";
contract C
{
	fn foo()  -> (u256) { L.normal(); }
	fn bar()  -> (u256) { L.reverting(); }
}
// ----
// Warning 6321: (s2.sol:67-71): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
// Warning 6321: (s2.sol:126-130): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
