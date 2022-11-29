contract C {
    struct S {
        u256 a;
        bool x;
    }
    S s;

    constructor() {
        3({a: 1, x: true});
    }
}
// ----
// TypeError 5704: (90-108): Type is not callable
