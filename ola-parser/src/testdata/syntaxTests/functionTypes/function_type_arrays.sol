contract C {
    fn(uint) external returns (uint)[] public x;
    fn(uint) internal returns (uint)[10] y;
    fn f() view public {
        fn(uint) returns (uint)[10] memory a;
        fn(uint) returns (uint)[10] storage b = y;
        fn(uint) external returns (uint)[] memory c;
        c = new fn(uint) external returns (uint)[](200);
        a; b;
    }
}
// ----
