==== Source: s1.sol ====
import "s1.sol" as A;

library L {
    fn f() internal pure {}
}

contract C
{
    fn test() public pure {
        A.L;
    }
}
// ----
// Warning 6133: (s1.sol:127-130): Statement has no effect.
