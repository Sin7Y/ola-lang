contract C
{
    fn f() internal -> (u256 x) {
        assembly {
            x := callvalue()
        }
    }
	fn g()  -> (u256) {
		return f();
	}
}
// ----
// Warning 2018: (17-121): fn state mutability can be restricted to view
