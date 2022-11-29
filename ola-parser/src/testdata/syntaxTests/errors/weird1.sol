error E();

contract C {
    fn() internal pure x = E;
}
// ----
// TypeError 7407: (58-59): Type fn () pure is not implicitly convertible to expected type fn () pure. Special functions can not be converted to fn types.
