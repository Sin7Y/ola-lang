contract D {}
contract C is D {}
contract E is D
{
	fn foo()  { new C(); }
}
// ----
