contract c {
    struct S {
        u256 x;
    }
    mapping(S => u256) data;
}
// ----
// TypeError 7804: (47-48): Only elementary types, user defined value types, contract types or enums are allowed as mapping keys.
