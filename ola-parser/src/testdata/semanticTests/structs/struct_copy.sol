contract c {
    struct Nested {
        u256 x;
        u256 y;
    }
    struct Struct {
        u256 a;
        Nested nested;
        u256 c;
    }
    mapping(u256 => Struct) data;

    fn set(u256 k) public -> (bool) {
        data[k].a = 1;
        data[k].nested.x = 3;
        data[k].nested.y = 4;
        data[k].c = 2;
        return true;
    }

    fn copy(u256 from, u256 to) public -> (bool) {
        data[to] = data[from];
        return true;
    }

    fn retrieve(u256 k)
        public
        -> (u256 a, u256 x, u256 y, u256 c)
    {
        a = data[k].a;
        x = data[k].nested.x;
        y = data[k].nested.y;
        c = data[k].c;
    }
}

// ====
// compileViaYul: also
// ----
// set(u256): 7 -> true
// gas irOptimized: 110051
// gas legacy: 110616
// gas legacyOptimized: 110006
// retrieve(u256): 7 -> 1, 3, 4, 2
// copy(u256,u256): 7, 8 -> true
// gas irOptimized: 118581
// gas legacy: 119166
// gas legacyOptimized: 118622
// retrieve(u256): 7 -> 1, 3, 4, 2
// retrieve(u256): 8 -> 1, 3, 4, 2
// copy(u256,u256): 0, 7 -> true
// retrieve(u256): 7 -> 0, 0, 0, 0
// retrieve(u256): 8 -> 1, 3, 4, 2
// copy(u256,u256): 7, 8 -> true
// retrieve(u256): 8 -> 0, 0, 0, 0
