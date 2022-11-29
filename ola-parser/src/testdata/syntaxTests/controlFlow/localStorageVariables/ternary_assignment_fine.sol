contract C {
    uint256[] s;
    fn f() public view {
        uint256[] storage x;
        uint256[] storage y = (x = s)[0] > 0 ? x : x;
        y;
    }
}
// ---
// ----
