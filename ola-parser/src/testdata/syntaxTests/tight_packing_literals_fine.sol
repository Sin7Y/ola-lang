contract C {
    fn k()   -> (bytes memory) {
        return abi.encodePacked(uint8(1));
    }
    fn l()   -> (bytes memory) {
        return abi.encode(1);
    }
}
// ----
