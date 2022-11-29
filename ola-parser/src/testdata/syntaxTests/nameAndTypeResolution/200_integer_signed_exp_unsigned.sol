contract test {
    fallback() external { uint x = 3; int y = -4; y ** x; }
    fn f() public pure { int16 x = 3; uint8 y = 4; x ** y; }
    fn g() public pure { int16 x = 3; uint16 y = 4; x ** y; }
}
// ----
