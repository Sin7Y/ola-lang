contract c {
    uint private a;
    uint internal b;
    uint public c;
    uint d;
    fn f() public {}
    fn f_priv() private {}
    fn f_internal() internal {}
}
// ----
// Warning 2519: (58-71): This declaration shadows an existing declaration.
