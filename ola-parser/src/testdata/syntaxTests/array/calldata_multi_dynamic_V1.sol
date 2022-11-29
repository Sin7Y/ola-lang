pragma abicoder v1;
contract Test {
    fn f(uint[][] calldata) external { }
    fn g(uint[][1] calldata) external { }
}
// ----
// TypeError 4957: (51-68): This type is only supported in ABI coder v2. Use "pragma abicoder v2;" to enable the feature.
// TypeError 4957: (98-116): This type is only supported in ABI coder v2. Use "pragma abicoder v2;" to enable the feature.
