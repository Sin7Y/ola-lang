interface I {
    fn f() external;
}

contract B {
    fn g() external pure returns(bytes4) {
        return I.f.selector;
    }
}
// ----
