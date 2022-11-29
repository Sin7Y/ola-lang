contract c {
    struct s { u256[][] d; }
    s[] data;
    fn fill()  -> (u256) {
        while (data.length < 3)
            data.push();
        while (data[2].d.length < 4)
            data[2].d.push();
        while (data[2].d[3].length < 5)
            data[2].d[3].push();
        data[2].d[3][4] = 8;
        return data[2].d[3][4];
    }
    fn clear()  { delete data; }
}
// ====
// compileViaYul: also
// ----
// storageEmpty -> 1
// fill() -> 8
// gas irOptimized: 122531
// gas legacy: 121756
// gas legacyOptimized: 120687
// storageEmpty -> 0
// clear() ->
// storageEmpty -> 1
