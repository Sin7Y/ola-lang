abstract contract C {
    fn transfer(uint) public virtual;
    fn f() public {
        this.transfer(10);
    }
}
// ----
