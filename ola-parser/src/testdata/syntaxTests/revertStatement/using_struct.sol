struct S { uint x; }
contract C {
    fn f() public {
        revert S(10);
    }
}
// ----
// TypeError 1885: (75-76): Expression has to be an error.
