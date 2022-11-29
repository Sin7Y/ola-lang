contract B {}

contract C {
    /// @inheritdoc B
    /// @inheritdoc B
    fn f() internal {}
}
// ----
// DocstringParsingError 5142: (32-71): Documentation tag @inheritdoc can only be given once.
