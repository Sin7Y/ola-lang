contract C {
    fn f()  -> (bytes32) {
        return address(this).codehash;
    }
    fn g()  -> (bytes32) {
        return address(0).codehash;
    }
}
// ====
// EVMVersion: >=constantinople
// ----
