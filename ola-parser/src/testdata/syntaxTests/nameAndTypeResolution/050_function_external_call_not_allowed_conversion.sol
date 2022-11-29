contract C {}
contract Test {
    fn externalCall() public {
        address arg;
        this.g(arg);
    }
    fn g (C c) external {}
}
// ----
// TypeError 9553: (103-106): Invalid type for argument in fn call. Invalid implicit conversion from address to contract C requested.
