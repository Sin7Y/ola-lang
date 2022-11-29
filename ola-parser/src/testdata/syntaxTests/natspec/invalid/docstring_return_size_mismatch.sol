abstract contract C {
    /// @param id Some identifier
    /// @return No value returned
    fn vote(u256 id)  virtual -> (u256 value);

    /// @return No value returned
    fn unvote(u256 id)  virtual -> (u256 value);
}
// ----
// DocstringParsingError 5856: (26-89): Documentation tag "@return No value returned" does not contain the name of its return parameter.
// DocstringParsingError 5856: (159-188): Documentation tag "@return No value returned" does not contain the name of its return parameter.
