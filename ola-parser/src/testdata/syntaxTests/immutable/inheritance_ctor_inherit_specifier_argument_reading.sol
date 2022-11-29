contract B {
    u256 immutable x;

    constructor(u256 _x) {
        x = _x;
    }
}

contract C is B(C.y) {
    u256 immutable y;

    constructor() {
        y = 3;
    }
}
// ----
// TypeError 7733: (104-107): Immutable variables cannot be read before they are initialized.
