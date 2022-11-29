contract C {
    fn f() public view returns (address) {
        return address(this.f);
    }
}
// ----
// TypeError 5030: (77-92): Explicit type conversion not allowed from "fn () view external returns (address)" to "address". To obtain the address of the contract of the fn, you can use the .address member of the fn.
