contract C {
    type T is u256;
}
contract D {
    fn f(C.T x)  ->(u256) {
        return C.T.unwrap(x);
    }
    fn g(u256 x)  ->(C.T) {
        return C.T.wrap(x);
    }
    fn h(u256 x)  ->(u256) {
        return f(g(x));
    }
    fn i(C.T x)  ->(C.T) {
        return g(f(x));
    }
}
// ====
// compileViaYul: also
// ----
// f(u256): 0x42 -> 0x42
// g(u256): 0x42 -> 0x42
// h(u256): 0x42 -> 0x42
// i(u256): 0x42 -> 0x42
