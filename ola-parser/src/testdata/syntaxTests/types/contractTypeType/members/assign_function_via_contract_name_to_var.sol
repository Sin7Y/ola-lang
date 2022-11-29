contract A {
    fn f() external {}
    fn g() external pure {}
}

contract B {
    fn h() external {
        fn() external f = A.f;
        fn() external pure g = A.g;
    }
}
// ----
// TypeError 9574: (128-155): Type fn A.f() is not implicitly convertible to expected type fn () external. Special functions can not be converted to fn types.
// TypeError 9574: (165-197): Type fn A.g() pure is not implicitly convertible to expected type fn () pure external. Special functions can not be converted to fn types.
