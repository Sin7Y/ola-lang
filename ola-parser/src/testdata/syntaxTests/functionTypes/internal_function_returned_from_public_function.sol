// It should not be possible to return internal functions from external functions.
contract C {
    fn f() public returns (fn(uint) internal returns (uint) x) {
    }
}
// ----
// TypeError 4103: (129-169): Internal type is not allowed for public or external functions.
