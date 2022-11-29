contract C {
    uint256[] x;
    fn f() public view {
        x[1:2];
    }
}
// ----
// TypeError 1227: (69-75): Index range access is only supported for dynamic calldata arrays.
