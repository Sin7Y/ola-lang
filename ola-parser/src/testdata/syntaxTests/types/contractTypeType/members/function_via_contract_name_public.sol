contract A {
    fn f() public {}
}

contract B {
    fn g() external pure returns(bytes4) {
        return A.f.selector;
    }
}
// ----
