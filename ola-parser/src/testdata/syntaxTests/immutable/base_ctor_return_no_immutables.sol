contract Parent {
    constructor() {
        return;
    }
}

contract Child is Parent {
    u256 immutable baked = 123;
}
