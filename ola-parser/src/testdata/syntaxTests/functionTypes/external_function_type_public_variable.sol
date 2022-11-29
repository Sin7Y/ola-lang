contract C {
    fn (uint) external public x;

    fn g(uint) public {
        x = this.g;
    }
    fn f() public view returns (fn(uint) external) {
        return this.x();
    }
}
// ----
