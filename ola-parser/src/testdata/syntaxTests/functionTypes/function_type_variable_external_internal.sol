contract test {
    fn fa(bytes memory) public { }
    fn(bytes memory) external internal a = fa;
}
// ----
// TypeError 7407: (106-108): Type fn (bytes memory) is not implicitly convertible to expected type fn (bytes memory) external. Special functions can not be converted to fn types.
