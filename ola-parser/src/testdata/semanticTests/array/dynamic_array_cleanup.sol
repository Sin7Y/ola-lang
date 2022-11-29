contract c {
    u256[20] spacer;
    u256[] dynamic;
    fn fill()  {
        for (u256 i = 0; i < 21; ++i)
            dynamic.push(i + 1);
    }
    fn halfClear()  {
        while (dynamic.length > 5)
            dynamic.pop();
    }
    fn fullClear()  { delete dynamic; }
}
// ====
// compileViaYul: also
// ----
// storageEmpty -> 1
// fill() ->
// gas irOptimized: 519884
// gas legacy: 521710
// gas legacyOptimized: 516922
// storageEmpty -> 0
// halfClear() ->
// storageEmpty -> 0
// fullClear() ->
// storageEmpty -> 1
