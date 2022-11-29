contract helper {
    fn getBalance()  payable -> (u256 myBalance) {
        return address(this).balance;
    }
}


contract test {
    helper h;

    constructor() payable {
        h = new helper();
    }

    fn sendAmount(u256 amount)  -> (u256 bal) {
        return h.getBalance{value: amount + 3, gas: 1000}();
    }
}

// ====
// compileViaYul: also
// ----
// constructor(), 20 wei ->
// gas irOptimized: 191991
// gas legacy: 266728
// gas legacyOptimized: 184762
// sendAmount(u256): 5 -> 8
