contract C {
    modifier m1(uint[] storage a) { _; }
    modifier m2(uint[] storage a) { _; }
    uint[] s;
    fn f() m1(b = s) m2(b) internal view returns (uint[] storage b) {}
}
// ----
