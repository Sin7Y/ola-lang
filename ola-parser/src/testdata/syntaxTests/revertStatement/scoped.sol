contract A {
    error E();
}
contract C {
    fn f() public pure {
        revert A.E();
    }
}
// ----
