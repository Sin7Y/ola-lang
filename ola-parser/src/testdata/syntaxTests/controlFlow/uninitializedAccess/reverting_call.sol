contract C
{
        fn iWillRevert() pure public { revert(); }

        fn test(bool _param) pure external returns(uint256)
        {
                if (_param) return 1;

                iWillRevert();
        }
}

