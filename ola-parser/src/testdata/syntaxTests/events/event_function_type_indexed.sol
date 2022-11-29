contract C {
	event Test(fn() external indexed);
	fn f() public {
		emit Test(this.f);
	}
}
// ----
