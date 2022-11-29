contract C
{
	fn iWillRevertLevel2(bool _recurse) pure public
	{
		if (_recurse)
			iWillRevertLevel1();
		else
			revert();
	}

	fn iWillRevertLevel1() pure public { iWillRevertLevel2(true); }
	fn iWillRevert() pure public { iWillRevertLevel1(); }

	fn test(bool _param) pure external returns(uint256)
	{
		if (_param) return 1;

		iWillRevert();
	}
}

// ----
