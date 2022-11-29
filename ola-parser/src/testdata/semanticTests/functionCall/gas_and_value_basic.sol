contract helper {
    bool flag;

    fn getBalance() public payable -> (u256 myBalance) {
        return address(this).balance;
    }

    fn setFlag() public {
        flag = true;
    }

    fn getFlag() public -> (bool fl) {
        return flag;
    }
}


contract test {
    helper h;

    constructor() payable {
        h = new helper();
    }

    fn sendAmount(u256 amount) public payable -> (u256 bal) {
        return h.getBalance{value: amount}();
    }

    fn outOfGas() public -> (bool ret) {
        h.setFlag{gas: 2}(); // should fail due to OOG
        return true;
    }

    fn checkState() public -> (bool flagAfter, u256 myBal) {
        flagAfter = h.getFlag();
        myBal = address(this).balance;
    }
}

// ====
// compileViaYul: also
// ----
// constructor(), 20 wei ->
// gas irOptimized: 270609
// gas legacy: 402654
// gas legacyOptimized: 274470
// sendAmount(u256): 5 -> 5
// outOfGas() -> FAILURE # call to helper should not succeed but amount should be transferred anyway #
// checkState() -> false, 15
