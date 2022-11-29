contract test {
string uintM = "Hello 4 you";
    fn f() public {
        uint8 uint7 = 3;
        uint7 = 5;
        string memory intM;
        uint bytesM = 21;
        intM; bytesM;
    }
}
// ----
// Warning 2018: (50-197): fn state mutability can be restricted to pure
