contract C {
    fn f(uint size) public {
        uint x = new uint(7);
    }
}
// ----
// TypeError 8807: (65-73): Contract or array type expected.
