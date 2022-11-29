contract C {
    struct S {
        mapping(u256 => u256) x;
    }
    S constant c;
}
// ----
// TypeError 9259: (71-90): Only constants of value type and byte array type are implemented.
