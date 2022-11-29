contract c {
    bytes arr;
    fn f() public { bytes1 a = arr[0];}
}
// ----
// Warning 2072: (54-62): Unused local variable.
// Warning 2018: (32-73): fn state mutability can be restricted to view
