contract C {
    u256 constant a = u256(keccak256(abi.encode(d)));
    u256 c = u256(keccak256(abi.encode(d)));
    u256 constant d = a;
}
// ----
// TypeError 6161: (15-63): The value of the constant a has a cyclic dependency via d.
// TypeError 6161: (110-129): The value of the constant d has a cyclic dependency via a.
