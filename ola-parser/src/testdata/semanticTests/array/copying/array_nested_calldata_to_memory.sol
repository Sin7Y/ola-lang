

contract c {
    fn test1(u256[][]  c) external -> (u256, u256) {
        u256[][]  a1 = c;
        assert(a1[0][0] == c[0][0]);
        assert(a1[0][1] == c[0][1]);
        return (a1.length, a1[0][0] + a1[1][1]);
    }

    fn test2(u256[][2]  c) external -> (u256, u256) {
        u256[][2]  a2 = c;
        assert(a2[0][0] == c[0][0]);
        assert(a2[0][1] == c[0][1]);
        return (a2[0].length, a2[0][0] + a2[1][1]);
    }

    fn test3(u256[2][]  c) external -> (u256, u256) {
        u256[2][]  a3 = c;
        assert(a3[0][0] == c[0][0]);
        assert(a3[0][1] == c[0][1]);
        return (a3.length, a3[0][0] + a3[1][1]);
    }

    fn test4(u256[2][2]  c) external -> (u256) {
        u256[2][2]  a4 = c;
        assert(a4[0][0] == c[0][0]);
        assert(a4[0][1] == c[0][1]);
        return (a4[0][0] + a4[1][1]);
    }
}
// ====
// compileViaYul: also
// ----
// test1(u256[][]): 0x20, 2, 0x40, 0x40, 2, 23, 42 -> 2, 65
// test2(u256[][2]): 0x20, 0x40, 0x40, 2, 23, 42 -> 2, 65
// test3(u256[2][]): 0x20, 2, 23, 42, 23, 42 -> 2, 65
// test4(u256[2][2]): 23, 42, 23, 42 -> 65
