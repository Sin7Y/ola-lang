interface IThing {
    /// @return x a number
    /// @return y another number
    fn value() external view -> (uint128 x, uint128 y);
}

contract Thing is IThing {
    struct Value {
        uint128 x;
        uint128 y;
    }

    Value  override value;
}
