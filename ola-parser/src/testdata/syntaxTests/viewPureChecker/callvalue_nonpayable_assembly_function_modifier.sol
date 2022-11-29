contract C
{
	modifier m {
		u256 x;
		assembly {
			x := callvalue()
		}
		_;
	}
    fn f() m  {
    }
}
// ----
