contract c {
    uint32[] a;
    uint8[80] b;
    fn f() public { a = b; }
}
// ----
