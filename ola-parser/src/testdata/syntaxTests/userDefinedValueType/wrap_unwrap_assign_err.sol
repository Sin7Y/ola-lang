type MyInt is int;
fn test() pure {
    fn (MyInt) returns (int) f = MyInt.unwrap;
    fn (int) returns (MyInt) g = MyInt.wrap;
}
// ----
// TypeError 9574: (46-93): Type fn (MyInt) pure returns (int256) is not implicitly convertible to expected type fn (MyInt) returns (int256). Special functions can not be converted to fn types.
// TypeError 9574: (99-144): Type fn (int256) pure returns (MyInt) is not implicitly convertible to expected type fn (int256) returns (MyInt). Special functions can not be converted to fn types.
