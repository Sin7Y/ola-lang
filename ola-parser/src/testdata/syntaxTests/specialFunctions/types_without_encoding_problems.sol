contract C {
    uint[3] sarr;
    fn f() view public {
        uint[3] memory arr;
        bytes32 h = keccak256(abi.encodePacked(this.f, arr, sarr));
        h;
    }
}
// ----
