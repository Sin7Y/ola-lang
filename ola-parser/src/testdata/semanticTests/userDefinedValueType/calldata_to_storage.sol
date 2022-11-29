pragma abicoder v2;

type Small is uint16;
type Left is bytes2;
struct S { uint8 a; Small b; Left c; uint8 d; }

contract C {
    S  s;
    Small[]  small;
    Left[]  l;
    fn f(S calldata _s) external {
        s = _s;
    }
    fn g(Small[] calldata _small) external -> (Small[] memory) {
        small = _small;
        return small;
    }
    fn h(Left[] calldata _left) external -> (Left[] memory) {
        l = _left;
        return l;
    }
}
// ====
// compileViaYul: also
// ----
// s() -> 0, 0, 0x00, 0
// f((uint8,uint16,bytes2,uint8)): 1, 0xff, "ab", 15 ->
// gas irOptimized: 44405
// gas legacy: 47200
// gas legacyOptimized: 44923
// s() -> 1, 0xff, 0x6162000000000000000000000000000000000000000000000000000000000000, 15
// g(uint16[]): 0x20, 3, 1, 2, 3 -> 0x20, 3, 1, 2, 3
// gas irOptimized: 69097
// gas legacy: 75466
// gas legacyOptimized: 74255
// small(u256): 0 -> 1
// small(u256): 1 -> 2
// h(bytes2[]): 0x20, 3, "ab", "cd", "ef" -> 0x20, 3, "ab", "cd", "ef"
// gas irOptimized: 69174
// gas legacy: 75156
// gas legacyOptimized: 74342
// l(u256): 0 -> 0x6162000000000000000000000000000000000000000000000000000000000000
// l(u256): 1 -> 0x6364000000000000000000000000000000000000000000000000000000000000
