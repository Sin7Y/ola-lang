contract C {
    struct S {
        u256 x;
        u256[] y;
    }
    S constant x = S(5, new u256[](4));
}
// ----
// TypeError 9259: (52-86): Only constants of value type and byte array type are implemented.
