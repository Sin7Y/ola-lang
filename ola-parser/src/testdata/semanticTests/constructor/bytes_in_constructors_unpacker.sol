contract Test {
    u256 m_x;
    bytes m_s;

    constructor(u256 x, bytes memory s) {
        m_x = x;
        m_s = s;
    }
}
// ====
// compileViaYul: also
// ----
// constructor(): 7, 0x40, 78, "abcdefghijklmnopqrstuvwxyzabcdef", "ghijklmnopqrstuvwxyzabcdefghijkl", "mnopqrstuvwxyz" ->
// gas irOptimized: 283829
// gas legacy: 309607
// gas legacyOptimized: 260566
// m_x() -> 7
// m_s() -> 0x20, 78, "abcdefghijklmnopqrstuvwxyzabcdef", "ghijklmnopqrstuvwxyzabcdefghijkl", "mnopqrstuvwxyz"
