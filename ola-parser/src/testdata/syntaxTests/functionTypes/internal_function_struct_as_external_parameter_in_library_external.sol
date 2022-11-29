library L {
    struct S
    {
        fn(uint) internal returns (uint)[] x;
    }
    fn f(S storage s) public { }
}
// ----
// TypeError 4103: (104-115): Internal type is not allowed for public or external functions.
