enum E { A }
contract C {
    fn f() public pure {
        E e = E.A;
        e;
    }
}
// ----
