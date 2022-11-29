contract c {
    u256 spacer1;
    u256 spacer2;
    u256[3] data;
    fn fill()  {
        for (u256 i = 0; i < data.length; ++i) data[i] = i+1;
    }
    fn clear()  { delete data; }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// storageEmpty -> 1
// fill() ->
// storageEmpty -> 0
// clear() ->
// storageEmpty -> 1
