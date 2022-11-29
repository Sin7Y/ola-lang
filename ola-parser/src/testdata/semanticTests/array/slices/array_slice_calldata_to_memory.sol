contract C {
    fn f(u32[]  b, u256 start, u256 end)  -> (u32) {
        u32[]  m = b[start:end];
        u256 len = end - start;
        assert(len == m.length);
        for (u256 i = 0; i < len; i++) {
            assert(b[start:end][i] == m[i]);
        }
        return [b[start:end]][0][0];
    }

    fn g(u32[]  b, u256 start, u256 end)  -> (u32[] ) {
        return b[start:end];
    }

    fn h1(u32[]  b)  -> (u32[] ) {
        return b;
    }

    fn h(u32[]  b, u256 start, u256 end)  -> (u32[] ) {
        return h1(b[start:end]);
    }
}
// ====
// compileViaYul: also
// ----
// f(int256[],u256,u256): 0x60, 1, 3, 4, 1, 2, 3, 4 -> 2
// g(int256[],u256,u256): 0x60, 1, 3, 4, 1, 2, 3, 4 -> 0x20, 2, 2, 3
// h(int256[],u256,u256): 0x60, 1, 3, 4, 1, 2, 3, 4 -> 0x20, 2, 2, 3
