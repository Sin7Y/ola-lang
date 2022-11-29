contract C {
    mapping(uint => uint[]) map;
    fn f() public {
        map[0].length = 4;
    }
}
// ----
// TypeError 7567: (80-93): Member "length" is read-only and cannot be used to resize arrays.
