contract First {
    fn fun() public returns (bool ret) {
        return 1 & 2 == 8 & 9 && 1 ^ 2 < 4 | 6;
    }
}
// ----
// Warning 2018: (21-117): fn state mutability can be restricted to pure
