==== Source: s1.sol ====
contract C
{
	fn normal(bool x)  -> (u256)
	{
		if (x)
			return xxx();
		else
			return yyy();
	}
	fn yyy()  -> (u256) { revert(); }
	fn bar()  -> (u256) { normal(true); }

	fn xxx()  virtual pure -> (u256) { return 1; }
}
==== Source: s2.sol ====
import "s1.sol";
contract D is C
{
	fn foo()  -> (u256) { normal(false); }
	fn xxx()  override pure ->(u256) { revert(); }
}
// ----
// Warning 6321: (s1.sol:215-219): Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
