contract C {
    fn f() public view returns (bytes32) {
        return address(this).codehash;
    }
}
// ====
// EVMVersion: >=constantinople
// ----
