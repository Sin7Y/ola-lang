contract C {
	int dummy;
    fn h_nonpayable() external { dummy = 1; }
    fn h_payable() payable external {}
    fn h_view() view external { dummy; }
    fn h_pure() pure external {}
    fn f() view external {
        fn () external g_nonpayable = this.h_nonpayable; g_nonpayable;
        fn () payable external g_payable = this.h_payable; g_payable;
        fn () view external g_view = this.h_view; g_view;
        fn () pure external g_pure = this.h_pure; g_pure;
    }
}
// ----
