abstract contract C {
    fn f() internal virtual returns(uint[] storage);
    fn g() internal virtual returns(uint[] storage s);
}
// ----
