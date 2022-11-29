contract test {
    struct s1 {
        uint8 x;
        bool y;
    }
    struct s2 {
        uint32 z;
        s1 s1data;
        mapping(uint8 => s2) recursive;
    }
    s2 data;
    fn check()  -> (bool ok) {
        return data.z == 1 && data.s1data.x == 2 &&
            data.s1data.y == true &&
            data.recursive[3].recursive[4].z == 5 &&
            data.recursive[4].recursive[3].z == 6 &&
            data.recursive[0].s1data.y == false &&
            data.recursive[4].z == 9;
    }
    fn set()  {
        data.z = 1;
        data.s1data.x = 2;
        data.s1data.y = true;
        data.recursive[3].recursive[4].z = 5;
        data.recursive[4].recursive[3].z = 6;
        data.recursive[0].s1data.y = false;
        data.recursive[4].z = 9;
    }
}
// ====
// compileViaYul: also
// ----
// check() -> false
// set() ->
// gas irOptimized: 134411
// gas legacy: 135277
// gas legacyOptimized: 134064
// check() -> true
