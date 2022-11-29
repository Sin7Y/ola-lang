contract test {
    fn a(uint a, uint b) public returns (uint r) {
        r = a + b;
    }
    fn b() public returns (uint r) {
        r = a({});
    }
}
// ----
// Warning 2519: (31-37): This declaration shadows an existing declaration.
// Warning 2519: (39-45): This declaration shadows an existing declaration.
// TypeError 6160: (153-158): Wrong argument count for fn call: 0 arguments given but expected 2.
