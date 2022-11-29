library L {
    // Used to cause internal error
    fn f(fn(uint) internal returns (uint)[] memory x) public { }
}
// ----
// TypeError 4103: (63-112): Internal type is not allowed for public or external functions.
