abstract contract C {
    /// @param id Some identifier
    /// @return value Some value
	/// @return value2 Some value 2
    fn vote(u256 id)  virtual -> (u256 value);
}
// ----
// DocstringParsingError 2604: (26-121): Documentation tag "@return value2 Some value 2" exceeds the number of return parameters.
