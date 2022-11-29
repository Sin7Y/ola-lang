contract D {
    struct S { u256 a; }
}

contract C is D {
    /// @inheritdoc D.S
    fn f() internal {
    }
}
// ----
// DocstringParsingError 1430: (63-82): Documentation tag @inheritdoc reference "D.S" is not a contract.
