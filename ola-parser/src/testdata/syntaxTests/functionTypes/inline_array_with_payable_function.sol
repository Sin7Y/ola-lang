contract D {
    fn f(uint a) external payable {}
    fn g(uint a) external {}
}

contract C {
    fn f() public {
        D d;
        [d.f{value: 1}, d.g][0](8);
    }
}
// ----
// TypeError 9563: (155-168): Invalid mobile type.
