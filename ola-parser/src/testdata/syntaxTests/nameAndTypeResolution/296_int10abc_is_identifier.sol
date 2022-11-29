contract test {
    fn f() public {
        uint uint10abc = 3;
        int int10abc = 4;
        uint10abc; int10abc;
    }
}
// ----
// Warning 2018: (20-130): fn state mutability can be restricted to pure
