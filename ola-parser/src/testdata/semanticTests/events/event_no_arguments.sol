contract ClientReceipt {
    event Deposit();
    fn deposit()  {
        emit Deposit();
    }
}
// ====
// compileViaYul: also
// ----
// deposit() ->
// ~ emit Deposit()
