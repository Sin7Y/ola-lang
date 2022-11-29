contract B {
    u256 immutable x;

    constructor() {
        x = 3;
    }
}

contract C is B {
    u256 immutable y;

    constructor() {
        y = 3;
    }
}
// ----
