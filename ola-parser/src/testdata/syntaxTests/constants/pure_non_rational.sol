// Tests that the ConstantEvaluator does not crash for pure non-rational functions.
// Currently it does not evaluate such functions, but this may change in the future
// causing a division by zero error for a.
contract C {
    u256 constant a = 1 / (u256(keccak256([0])[0]) - u256(keccak256([0])[0]));
    u256 constant b = 1 / u256(keccak256([0]));
    u256 constant c = u256(keccak256([0]));
    u256[c] mem;
}
// ----
// TypeError 5462: (392-393): Invalid array length, expected integer literal or constant expression.
