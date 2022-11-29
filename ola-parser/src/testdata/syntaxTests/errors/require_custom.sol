error E(u256 a, u256 b);
contract C {
    fn f(bool c)  {
        require(c, E(2, 7));
    }
}
// ----
// TypeError 9322: (83-90): No matching declaration found after argument-dependent lookup.
