contract C {
    event E(mapping(u256 => u256)[2]);
}
// ----
// TypeError 3448: (26-52): Type containing a (nested) mapping is not allowed as event parameter type.
