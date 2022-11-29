pragma abicoder               v2;
contract Test {
    struct S { int a; }
    fn f(S calldata s) external { s.a = 4; }
}
// ----
// TypeError 4156: (114-117): Calldata structs are read-only.
