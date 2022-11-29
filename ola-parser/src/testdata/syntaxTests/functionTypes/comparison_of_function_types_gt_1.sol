contract C {
    fn f() public returns (bool ret) {
        return this.f > this.f;
    }
}
// ----
// TypeError 2271: (73-88): Operator > not compatible with types fn () external returns (bool) and fn () external returns (bool)
