contract C {
    constructor(u256) {}
}

contract D is C {
    u256 immutable t;

    constructor() C(t = 2) {}
}
// ----
// TypeError 1581: (92-93): Cannot write to immutable here: Immutable variables can only be initialized inline or assigned directly in the constructor.
