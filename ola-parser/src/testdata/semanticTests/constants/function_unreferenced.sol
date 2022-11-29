contract B {
    fn g()  {}
}
contract C is B {
    bytes4 constant s2 = B.g.selector;
    fn f() external pure -> (bytes4) { return s2; }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f() -> 0xe2179b8e00000000000000000000000000000000000000000000000000000000
