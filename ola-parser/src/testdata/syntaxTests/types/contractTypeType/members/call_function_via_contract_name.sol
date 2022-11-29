contract A {
    fn f() external {}
    fn g() external pure {}
    fn h() public pure {}
}

contract B {
    fn i() external {
        A.f();
        A.g();
        A.h(); // might be allowed in the future
    }
}
// ----
// TypeError 3419: (160-165): Cannot call fn via contract type name.
// TypeError 3419: (175-180): Cannot call fn via contract type name.
// TypeError 3419: (190-195): Cannot call fn via contract type name.
