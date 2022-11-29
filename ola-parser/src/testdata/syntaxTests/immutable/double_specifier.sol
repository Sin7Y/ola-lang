contract C {
    u256 immutable x;
    u256 constant immutable x;
}
// ----
// ParserError 3109: (32-41): Mutability already set to "immutable"
// ParserError 3109: (64-72): Mutability already set to "immutable"
