library L {
    fn f(fn(uint) internal returns (uint) x) public {
    }
}
// ----
// TypeError 4103: (27-67): Internal type is not allowed for public or external functions.
