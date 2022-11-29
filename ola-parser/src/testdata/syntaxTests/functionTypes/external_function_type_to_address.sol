contract C {
    fn f() public view returns (address) {
        return this.f.address;
    }
}
// ----
