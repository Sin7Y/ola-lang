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

    fn sendAmount(u256 amount)  payable -> (u256 bal) {
        u256 someStackElement = 20;
        return h.getBalance{value: amount + 3, gas: 1000}();
    }
}

// ====
// compileViaYul: also
// ----
// constructor(), 20 wei ->
// gas irOptimized: 190275
// gas legacy: 265006
// gas legacyOptimized: 182842
// sendAmount(u256): 5 -> 8
