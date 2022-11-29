contract C {
    fn f() public view returns (uint) {
        return block.basefee;
    }
    fn g() public view returns (uint ret) {
        assembly {
            ret := basefee()
        }
    }
}
// ====
// EVMVersion: >=london
// ----
