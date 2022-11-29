contract C {
    fn f() public view returns (address payable) {
        return block.coinbase;
    }
    fn g() public view returns (uint) {
        return block.difficulty;
    }
    fn h() public view returns (uint) {
        return block.gaslimit;
    }
    fn i() public view returns (uint) {
        return block.timestamp;
    }
    fn j() public view returns (uint) {
        return block.chainid;
    }
}
// ====
// EVMVersion: <istanbul
// ----
// TypeError 3081: (420-433): "chainid" is not supported by the VM version.
