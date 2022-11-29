contract c {
    uint32[] a;
    uint8[] b;
    fn f() public { a = b; }
}
// ----
