interface I {
    fn f(u256[] calldata) external pure;
}
contract A is I {
    fn f(u256[] memory)  {}
}
contract C {
    fn f()  {
        I i = I(new A());
        i.f(new u256[](1));
    }
}
// ----
