contract C {
    fn g() internal pure returns (bytes calldata) {
        return msg.data;
    }
    fn h(uint[] calldata _c) internal pure {
        uint[] calldata c;
        c = _c;
        c[2];
    }
    fn i(uint[] calldata _c) internal pure {
        uint[] calldata c;
        (c) = _c;
        c[2];
    }
}
// ----
