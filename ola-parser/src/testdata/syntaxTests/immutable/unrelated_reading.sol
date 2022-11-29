contract C {
    uint immutable x = 1;

    fn readX() internal pure returns(uint) {
        return x + 3;
    }
}
// ----
