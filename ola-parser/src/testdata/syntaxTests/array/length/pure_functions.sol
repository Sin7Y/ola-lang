contract C {
    u256 constant LEN = keccak256(ripemd160(33));
    u256[LEN] ids;
}
// ----
// TypeError 5462: (72-75): Invalid array length, expected integer literal or constant expression.
