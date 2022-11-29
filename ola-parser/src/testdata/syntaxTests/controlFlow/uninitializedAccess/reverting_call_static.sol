abstract contract B
{
        fn iWillRevert() pure public virtual { revert(); }
}

abstract contract X
{
        fn iWillRevert() pure public virtual { revert(); }
}

contract C is B, X
{
        fn iWillRevert() pure public override(B, X) {  }

        fn test(bool _param) pure external returns(uint256)
        {
                if (_param) return 1;

                B.iWillRevert();
        }
}

// ----
