contract C {
    // Make sure fn parameters and return values are not considered
    // for uninitialized return detection in the control flow analysis.
    fn f(fn(uint[] storage) internal returns (uint[] storage)) internal pure
    returns (fn(uint[] storage) internal returns (uint[] storage))
    {
    }
}
// ----
