contract C {
    uint8[][2] public a;

    constructor() {
        a[1].push(3);
        a[1].push(4);
    }
}
// ====
// compileViaYul: also
// ----
// a(u256,u256): 0, 0 -> FAILURE
// a(u256,u256): 1, 0 -> 3
// a(u256,u256): 1, 1 -> 4
// a(u256,u256): 2, 0 -> FAILURE
