contract C {
    uint a;
}
contract Test {
    address a;
    fn g (C c) public {}
    fn internalCall() public {
        g(a);
    }
}
// ----
// TypeError 9553: (136-137): Invalid type for argument in fn call. Invalid implicit conversion from address to contract C requested.
