pragma abicoder               v2;


contract C {
    fn f(uint256[][1][] calldata a) external returns (uint256) {
        return 42;
    }

    fn g(uint256[][1][] calldata a) external returns (uint256) {
        a[0];
        return 42;
    }

    fn h(uint256[][1][] calldata a) external returns (uint256) {
        a[0][0];
        return 42;
    }
}
// ====
// compileViaYul: also
// ----
// f(uint256[][1][]): 0x20, 0x0 -> 42 # valid access stub #
// f(uint256[][1][]): 0x20, 0x1 -> FAILURE # invalid on argument decoding #
// f(uint256[][1][]): 0x20, 0x1, 0x20 -> 42 # invalid on outer access #
// g(uint256[][1][]): 0x20, 0x1, 0x20 -> FAILURE
// f(uint256[][1][]): 0x20, 0x1, 0x20, 0x20 -> 42 # invalid on inner access #
// g(uint256[][1][]): 0x20, 0x1, 0x20, 0x20 -> 42
// h(uint256[][1][]): 0x20, 0x1, 0x20, 0x20 -> FAILURE
// f(uint256[][1][]): 0x20, 0x1, 0x20, 0x20, 0x1 -> 42
// g(uint256[][1][]): 0x20, 0x1, 0x20, 0x20, 0x1 -> 42
// h(uint256[][1][]): 0x20, 0x1, 0x20, 0x20, 0x1 -> FAILURE
