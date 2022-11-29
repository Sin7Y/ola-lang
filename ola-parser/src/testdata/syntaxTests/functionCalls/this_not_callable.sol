contract C {
    fn f() public returns (uint, uint) {
        try this() {
        } catch Error(string memory) {
        }
    }
}
// ----
// TypeError 5704: (72-78): Type is not callable
