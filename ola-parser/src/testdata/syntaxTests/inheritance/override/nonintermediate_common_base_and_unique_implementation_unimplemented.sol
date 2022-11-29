interface I {
	fn f() external;
	fn g() external;
}
interface J {
	fn f() external;
}
abstract contract IJ is I, J {
	fn f() external virtual override (I, J);
}
abstract contract A is IJ
{
	fn f() external virtual override;
}
abstract contract B is IJ
{
	fn g() external override {}
}
abstract contract C is A, B {}
// ----
