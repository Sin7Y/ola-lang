contract Base {
    uint public m_x;
    bytes m_s;
    constructor(uint x, bytes memory s) {
        m_x = x;
        m_s = s;
    }
    fn part(uint i) public -> (bytes1) {
        return m_s[i];
    }
}
contract Main is Base {
    constructor(bytes memory s, uint x) Base(x, f(s)) {}
    fn f(bytes memory s) public -> (bytes memory) {
        return s;
    }
}
contract Creator {
    fn f(uint x, bytes memory s) public -> (uint r, bytes1 ch) {
        Main c = new Main(s, x);
        r = c.m_x();
        ch = c.part(x);
    }
}
// ====
// compileViaYul: also
// ----
// f(u256,bytes): 7, 0x40, 78, "abcdefghijklmnopqrstuvwxyzabcdef", "ghijklmnopqrstuvwxyzabcdefghijkl", "mnopqrstuvwxyz" -> 7, "h"
// gas irOptimized: 293203
// gas legacy: 428711
// gas legacyOptimized: 297922
