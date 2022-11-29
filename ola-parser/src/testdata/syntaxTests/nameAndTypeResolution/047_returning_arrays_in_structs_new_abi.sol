pragma abicoder               v2;

contract C {
    struct S { string[] s; }
    fn f() public pure returns (S memory) {}
}
// ----
