contract C {
    u256 constant a = b * c;
    u256 constant b = 7;
    u256 constant c = b + u256(keccak256(abi.encodePacked(d)));
    u256 constant d = 2 + a;
}
// ----
// TypeError 6161: (17-40): The value of the constant a has a cyclic dependency via c.
// TypeError 6161: (71-129): The value of the constant c has a cyclic dependency via d.
// TypeError 6161: (135-158): The value of the constant d has a cyclic dependency via a.
