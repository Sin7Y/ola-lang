contract C {
    u256 immutable a;
    u256 immutable b;
    u256 immutable c;
    u256 immutable d;

    constructor() {
        a = 1;
        b = a;
        c = b;
        d = c;
    }
}
// ====
// compileViaYul: also
// ----
// a() -> 1
// b() -> 1
// c() -> 1
// d() -> 1
