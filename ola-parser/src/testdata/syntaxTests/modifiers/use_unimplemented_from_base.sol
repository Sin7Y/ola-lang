abstract contract A {
    modifier m() virtual;
    fn f() m  {}
}
contract B is A {
    modifier m() virtual override { _; }
}
// ----
