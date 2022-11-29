enum E { A }
contract C {
    enum E { A }
    fn f() public pure {
        E e = E.A;
        e;
    }
}
// ----
// Warning 2519: (30-42): This declaration shadows an existing declaration.
