contract C {
    fn(uint) external returns (uint) x;
    fn(uint) internal returns (uint) y;
    fn f() public {
        delete x;
        fn(uint) internal returns (uint) a = y;
        delete a;
        delete y;
        fn() internal c = f;
        delete c;
        fn(uint) internal returns (uint) g;
        delete g;
    }
}
// ----
