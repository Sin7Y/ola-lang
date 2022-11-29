contract Test {
    u32[]  data;
    fn set(u32[]  _data)  -> (u256) {
        data = _data;
        return data.length;
    }
    fn get()  -> (u32[] ) {
        return data;
    }
}
// ====
// compileViaYul: also
// ----
// set(u32[]): 0x20, 18, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 -> 18
// gas irOptimized: 99616
// gas legacy: 103563
// gas legacyOptimized: 101397
// data(u256): 7 -> 8
// data(u256): 15 -> 16
// data(u256): 18 -> FAILURE
// get() -> 0x20, 18, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18
