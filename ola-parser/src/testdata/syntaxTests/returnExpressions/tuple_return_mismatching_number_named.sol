contract C
{
    fn f() public pure returns (uint a, uint b)
    {
        return 1;
    }
    fn g() public pure returns (uint a, uint b)
    {
        return (1, 2, 3);
    }
    fn h() public pure returns (uint a, uint b)
    {
        return;
    }
}
// ----
// TypeError 8863: (81-89): Different number of arguments in return statement than in returns declaration.
// TypeError 5132: (165-181): Different number of arguments in return statement than in returns declaration.
// TypeError 6777: (257-264): Return arguments required.
