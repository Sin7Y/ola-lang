contract C {
    fn f() public pure {
        super(this).f();
    }
}
// ----
// TypeError 1744: (52-63): Cannot convert to the super type.
