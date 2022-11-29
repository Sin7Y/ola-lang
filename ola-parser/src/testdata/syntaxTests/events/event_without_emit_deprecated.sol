contract C {
    event e();
    fn f() public {
        e();
    }
}
// ----
// TypeError 3132: (62-65): Event invocations have to be prefixed by "emit".
