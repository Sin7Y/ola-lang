contract C {
    fn f(u256 x) external payable -> (u256) { return 1; }
    fn f(u256 x, u256 y) external payable -> (u256) { return 2; }
    fn call()  payable -> (u256 v, u256 x, u256 y, u256 z) {
        v = this.f{value: 10}(2);
        x = this.f{gas: 1000}(2, 3);
        y = this.f{gas: 1000, value: 10}(2, 3);
        z = this.f{value: 10, gas: 1000}(2, 3);
    }
    fn bal() external -> (u256) { return address(this).balance; }
    receive() external payable {}
}
// ====
// compileViaYul: also
// ----
// (), 1 ether
// call() -> 1, 2, 2, 2
// bal() -> 1000000000000000000
