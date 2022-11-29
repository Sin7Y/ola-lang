contract C
{
    fn f() public pure {
        return;
    }
    fn g() public pure returns (uint) {
        return 1;
    }
    fn h() public pure returns (uint a) {
        return 1;
    }
    fn i() public pure returns (uint, uint) {
        return (1, 2);
    }
    fn j() public pure returns (uint a, uint b) {
        return (1, 2);
    }
}
// ----
