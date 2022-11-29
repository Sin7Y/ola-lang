contract test {
    constructor() payable {}

    fn getBalance()  -> (u256 balance) {
        return address(this).balance;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// constructor(), 23 wei ->
// getBalance() -> 23
