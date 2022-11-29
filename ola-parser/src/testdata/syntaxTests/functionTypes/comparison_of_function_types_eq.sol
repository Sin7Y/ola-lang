contract C {
    fn f() public returns (bool ret) {
        return f == f;
    }
    fn g() public returns (bool ret) {
        return f != f;
    }
}
// ----
// Warning 2018: (17-86): fn state mutability can be restricted to pure
// Warning 2018: (91-160): fn state mutability can be restricted to pure
