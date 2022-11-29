abstract contract I
{
    fn a() internal view virtual ->(u256);
}
abstract contract J is I
{
    fn a() internal view virtual override ->(u256);
}
abstract contract V is J
{
    fn b() public view ->(u256) { return a(); }
}
contract C is V
{
    fn a() internal view override -> (u256) { return 42; }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// b() -> 42
