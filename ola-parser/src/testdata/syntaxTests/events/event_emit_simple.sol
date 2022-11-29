contract C {
    event e();
    fn f() public {
        emit e();
    }
}
// ----
