contract C {
    u256 immutable x = 3;

    constructor() {
        delete x;
    }
}
// ----
// TypeError 2718: (74-75): Immutable variables cannot be modified after initialization.
