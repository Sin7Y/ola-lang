contract c {
    struct Data { u256 x; u256 y; }
    Data[] data1;
    Data[] data2;
    fn test()  -> (u256 x, u256 y) {
        while (data1.length < 9)
            data1.push();
        data1[8].x = 4;
        data1[8].y = 5;
        data2 = data1;
        x = data2[8].x;
        y = data2[8].y;
        while (data1.length > 0)
            data1.pop();
        data2 = data1;
    }
}
// ====
// compileViaYul: also
// ----
// test() -> 4, 5
// gas irOptimized: 238799
// gas legacy: 238736
// gas legacyOptimized: 237159
// storageEmpty -> 1
