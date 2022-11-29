contract B {
    u256 immutable x;

    constructor(u256 _x) {
        x = _x;
    }
}

contract C is B {
    u256 immutable y;

    constructor() B(y = 3) {}
}
// ----
// TypeError 1581: (148-149): Cannot write to immutable here: Immutable variables can only be initialized inline or assigned directly in the constructor.
