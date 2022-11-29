contract c {
    uint[] storageArray;
    fn f() public {
        storageArray.length = 3;
    }
}
// ----
// TypeError 7567: (72-91): Member "length" is read-only and cannot be used to resize arrays.
