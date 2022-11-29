pragma abicoder               v2;
library c {
    struct S { uint x; }
    fn f() public returns (S memory) {}
}
// ----
