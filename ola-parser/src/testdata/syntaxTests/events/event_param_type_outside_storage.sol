contract c {
    event e(
        u256 indexed a,
        mapping(u256 => u256) indexed b,
        bool indexed c,
        u256 indexed d,
        u256 indexed e
    ) anonymous;
}
// ----
// TypeError 3448: (41-72): Type containing a (nested) mapping is not allowed as event parameter type.
