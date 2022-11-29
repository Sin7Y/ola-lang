contract C {
    struct S { u256 a; }
    /// @inheritdoc S
    fn f() internal {
    }
}
// ----
// DocstringParsingError 1430: (42-59): Documentation tag @inheritdoc reference "S" is not a contract.
