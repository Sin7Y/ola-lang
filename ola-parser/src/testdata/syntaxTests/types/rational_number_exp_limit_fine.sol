contract c {
    fn f() public pure {
        int a;
        a = 0 ** 1E1233;
        a = 1 ** 1E1233;
        a = -1 ** 1E1233;
        a = 0E123456789;
    }
}
// ----
