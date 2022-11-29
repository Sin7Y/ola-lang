abstract contract I
{
    fn a() internal view virtual returns(uint256);
}
abstract contract V is I
{
    fn b() public view returns(uint256) { return a(); }
}
// ----
