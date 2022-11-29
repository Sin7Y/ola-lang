abstract contract B
{
        fn iWillRevert() pure public virtual { }
}

contract C is B
{
        fn iWillRevert() pure public override { revert(); }

        fn test(bool _param) pure external returns(uint256)
        {
                if (_param) return 1;

                iWillRevert();
        }
}

// ----
