contract ClientReceipt {
    event Deposit(uint fixeda, bytes dynx, uint fixedb);
    fn deposit() public {
        emit Deposit(10, msg.data, 15);
    }
}
// ====
// compileViaYul: also
// ----
// deposit() ->
// ~ emit Deposit(u256,bytes,u256): 0x0a, 0x60, 0x0f, 0x04, 0xd0e30db000000000000000000000000000000000000000000000000000000000
