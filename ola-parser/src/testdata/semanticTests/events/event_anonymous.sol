contract ClientReceipt {
    event Deposit() anonymous;
    fn deposit()  {
        emit Deposit();
    }
}
// ====
// compileViaYul: also
// ----
// deposit() ->
// ~ emit <anonymous>
