contract C {
    fn x(bool) public {}
    fn y() public {}

    fn f() public {
        true ? x : y;
    }
}
// ----
// TypeError 1080: (106-118): True expression's type fn (bool) does not match false expression's type fn ().
