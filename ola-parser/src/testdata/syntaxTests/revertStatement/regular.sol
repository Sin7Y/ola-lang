error E();
contract C {
    fn f() public pure {
        revert E();
    }
}
// ----
