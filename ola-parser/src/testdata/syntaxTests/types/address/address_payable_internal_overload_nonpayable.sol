contract C {
    fn f(address payable) internal pure {}
    fn f(address) internal pure returns (uint) {}
    fn g() internal pure {
        address a = address(0);
        uint b = f(a); // TODO: should this be valid?
        b;
    }
}
// ----
