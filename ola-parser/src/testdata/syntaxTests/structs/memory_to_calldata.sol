pragma abicoder               v2;
contract Test {
    struct S { int a; }
    fn f(S calldata s) external { s = S(2); }
    fn g(S calldata s) external { S memory m; s = m; }
}
// ----
// TypeError 7407: (118-122): Type struct Test.S memory is not implicitly convertible to expected type struct Test.S calldata.
// TypeError 7407: (182-183): Type struct Test.S memory is not implicitly convertible to expected type struct Test.S calldata.
