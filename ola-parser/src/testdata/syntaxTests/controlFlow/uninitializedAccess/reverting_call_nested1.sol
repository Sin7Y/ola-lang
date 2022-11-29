contract C
{
        fn iWillRevertLevel2() pure public { revert(); }
        fn iWillRevertLevel1() pure public { iWillRevertLevel2(); }
        fn iWillRevert() pure public { iWillRevertLevel1(); }

        fn test(bool _param) pure external returns(uint256)
        {
                if (_param) return 1;

                iWillRevert();
        }
}

