contract B {
    u256 immutable x;

    constructor(u256 _x) {
        x = _x;
    }
}

contract C is B(C.y = 3) {
    u256 immutable y;
}
// ----
// TypeError 1581: (104-107): Cannot write to immutable here: Immutable variables can only be initialized inline or assigned directly in the constructor.
