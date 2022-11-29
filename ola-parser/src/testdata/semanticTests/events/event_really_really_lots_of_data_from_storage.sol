contract ClientReceipt {
    bytes x;
    event Deposit(uint fixeda, bytes dynx, uint fixedb);
    fn deposit() public {
        x = new bytes(31);
        x[0] = "A";
        x[1] = "B";
        x[2] = "C";
        x[30] = "Z";
        emit Deposit(10, x, 15);
    }
}
// ====
// compileViaYul: also
// ----
// deposit() ->
// ~ emit Deposit(u256,bytes,u256): 0x0a, 0x60, 0x0f, 0x1f, "ABC\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Z"
