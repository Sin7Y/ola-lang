pragma solidity >0.4.24;

contract C
{
	fn f(uint x) public pure {
		for (uint i = 0; i < x; ++i)
			uint y;
	}
}
// ----
// SyntaxError 9079: (107-113): Variable declarations can only be used inside blocks.
