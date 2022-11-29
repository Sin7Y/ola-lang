contract C
{
	// Internal uncalled fn should not cause an cyclic dep. error
	fn foo() internal { new D(); }
	fn callFoo() virtual  { foo(); }
}

contract D is C
{
	fn callFoo() override  {}
}
// ----
