contract C {
    mapping(u256 => u256) constant x;
}
// ----
// TypeError 9259: (17-49): Only constants of value type and byte array type are implemented.
