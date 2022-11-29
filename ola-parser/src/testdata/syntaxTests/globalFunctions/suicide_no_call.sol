contract C
{
	fn f(bytes memory data)  {
		suicide;
	}
}
// ----
// TypeError 8050: (60-67): "suicide" has been deprecated in favour of "selfdestruct".
