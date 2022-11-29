contract C {
    struct S { uint256 x; }
	fn i() internal pure {}
	fn e() external pure {}
	uint[] s1;
    fn f(uint x, bytes32 y) external {
        x = 42;
        y = bytes32(0);
        (x, y) = (23, bytes32(0));
        S memory ms1;
        S memory ms2;
        ms1 = ms2;
        ms1.x = x;
        uint256[] memory a = new uint256[](2);
        uint256[] memory b = new uint256[](3);
        a = b;
        a[0] = x;
        s1[0] = x;
        s1 = a;
    }
    fn g(fn() internal pure x) internal view {
        x = i;
        fn(uint, bytes32) external y;
        y = this.f;
    }
    fn g(fn() external pure x) external view {
        x = this.e;
        fn(fn() internal pure) internal view y;
        y = g;
    }
}
// ----
