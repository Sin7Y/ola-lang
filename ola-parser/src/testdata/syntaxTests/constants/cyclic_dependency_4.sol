contract C {
    u256 constant a = b * c;
    u256 constant b = 7;
    u256 constant c = 4 + u256(keccak256(abi.encode(d)));
    u256 constant d = 2 + b;
}
// ----
