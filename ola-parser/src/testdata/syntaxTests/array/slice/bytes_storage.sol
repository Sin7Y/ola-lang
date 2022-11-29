contract C {
    bytes x;
    fn f() public view {
        x[1:2];
    }
}
// ----
// TypeError 1227: (65-71): Index range access is only supported for dynamic calldata arrays.
