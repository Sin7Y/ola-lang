error E(u256 a, u256 b);
contract C {
    fn f()  {
        revert(E(2, 7));
    }
}
// ----
// TypeError 9322: (77-83): No matching declaration found after argument-dependent lookup.
