contract C {
    fn f1() public pure returns (bool) {
        return (-4266 >> 0) == -4266;
    }

    fn f2() public pure returns (bool) {
        return (-4266 >> 1) == -2133;
    }

    fn f3() public pure returns (bool) {
        return (-4266 >> 4) == -267;
    }

    fn f4() public pure returns (bool) {
        return (-4266 >> 8) == -17;
    }

    fn f5() public pure returns (bool) {
        return (-4266 >> 16) == -1;
    }

    fn f6() public pure returns (bool) {
        return (-4266 >> 17) == -1;
    }

    fn g1() public pure returns (bool) {
        return (-4267 >> 0) == -4267;
    }

    fn g2() public pure returns (bool) {
        return (-4267 >> 1) == -2134;
    }

    fn g3() public pure returns (bool) {
        return (-4267 >> 4) == -267;
    }

    fn g4() public pure returns (bool) {
        return (-4267 >> 8) == -17;
    }

    fn g5() public pure returns (bool) {
        return (-4267 >> 16) == -1;
    }

    fn g6() public pure returns (bool) {
        return (-4267 >> 17) == -1;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f1() -> true
// f2() -> true
// f3() -> true
// f4() -> true
// f5() -> true
// f6() -> true
// g1() -> true
// g2() -> true
// g3() -> true
// g4() -> true
// g5() -> true
// g6() -> true
