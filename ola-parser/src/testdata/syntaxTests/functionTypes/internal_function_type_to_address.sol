contract C {
    fn f() public returns (address) {
        return address(f);
    }
}
// ----
// TypeError 9640: (72-82): Explicit type conversion not allowed from "fn () returns (address)" to "address".
