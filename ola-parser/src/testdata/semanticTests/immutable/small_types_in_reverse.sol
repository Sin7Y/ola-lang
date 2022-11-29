contract A {
    uint16 public immutable a;
    uint16 public immutable b;
    uint16 public immutable c;
    uint16[3] public x;

    constructor() {
        c = 0xffff;
        b = 0x0f0f;
        a = 0x1234;
        x = [a, b, c];
    }
}
// ====
// compileViaYul: also
// ----
// a() -> 4660
// b() -> 0x0f0f
// c() -> 0xffff
// x(u256): 0 -> 4660
// x(u256): 1 -> 0x0f0f
// x(u256): 2 -> 0xffff
