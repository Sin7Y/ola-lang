pragma abicoder v1;

contract c {
    event E(u256[][]);
}
// ----
// TypeError 3061: (45-53): This type is only supported in ABI coder v2. Use "pragma abicoder v2;" to enable the feature.
