contract C {
    fn f() public returns (uint) {
        return uint(this.f);
    }
}
// ----
// TypeError 9640: (69-81): Explicit type conversion not allowed from "fn () external returns (uint256)" to "uint256".
