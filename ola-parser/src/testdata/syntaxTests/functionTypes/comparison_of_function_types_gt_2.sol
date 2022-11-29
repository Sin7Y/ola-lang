contract C {
    fn f() public returns (bool ret) {
        return f > f;
    }
}
// ----
// TypeError 2271: (73-78): Operator > not compatible with types fn () returns (bool) and fn () returns (bool)
