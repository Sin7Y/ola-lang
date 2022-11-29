contract D {
}

contract C is D {
    /// @inheritdoc D
    fn f() internal {
    }
}
// ----
// DocstringParsingError 4682: (38-55): Documentation tag @inheritdoc references contract "D", but the contract does not contain a fn that is overridden by this fn.
