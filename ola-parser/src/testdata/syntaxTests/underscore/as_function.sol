contract C {
    fn _() public pure {
    }

    fn g() public pure {
        _();
    }

    fn h() public pure {
        _;
    }
}
// ----
