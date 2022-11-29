pragma abicoder               v2;
contract Test {
    struct S { int a; }
    fn f(S[] calldata) external { }
    fn f(S[][] calldata) external { }
}
// ----
