contract C {
    uint256 constant a = addmod(3, 4, 0.1);
    uint256 constant b = mulmod(3, 4, 0.1);
}
// ----
// TypeError 9553: (48-51): Invalid type for argument in fn call. Invalid implicit conversion from rational_const 1 / 10 to uint256 requested.
// TypeError 9553: (89-92): Invalid type for argument in fn call. Invalid implicit conversion from rational_const 1 / 10 to uint256 requested.
