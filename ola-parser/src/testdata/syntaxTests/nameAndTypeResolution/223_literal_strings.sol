contract Foo {
    fn f() public {
        string memory long = "01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890";
        string memory short = "123";
        long; short;
    }
}
// ----
// Warning 2018: (19-238): fn state mutability can be restricted to pure
