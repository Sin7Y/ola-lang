contract C {
    fn f() public pure {
        uint a = 0;
        while (a < 100) {
            a++;
            break;
            a--;
        }
    }
}
// ----
// Warning 5740: (138-141): Unreachable code.
