abstract contract B
{
        fn iWillRevert() pure public virtual { revert(); }
}

contract C is B
{
        fn iWillRevert() pure public override {  }

        fn test(bool _param) pure external returns(uint256)
        {
                if (_param) return 1;

                super.iWillRevert();
        }
}

// ----
