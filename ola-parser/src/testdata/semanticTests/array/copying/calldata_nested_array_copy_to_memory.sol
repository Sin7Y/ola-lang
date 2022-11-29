

contract Test {
    struct shouldBug {
        u256[][2] deadly;
    }
    fn killer(u256[][2]  weapon)   -> (shouldBug ) {
        return shouldBug(weapon);
    }
}
// ====
// compileViaYul: also
// ----
// killer(u256[][2]): 0x20, 0x40, 0x40, 2, 1, 2 -> 0x20, 0x20, 0x40, 0xa0, 2, 1, 2, 2, 1, 2
