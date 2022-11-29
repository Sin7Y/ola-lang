contract C {
    fn f(address payable a) public {
        selfdestruct(a);
    }
}
// ----
