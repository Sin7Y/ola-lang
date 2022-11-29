contract A {
    fn f() external {}
}

contract B {
    fn g() external pure returns(bytes4) {
        return A.f.selector;
    }
}
// ----
