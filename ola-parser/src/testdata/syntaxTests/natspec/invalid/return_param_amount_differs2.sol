interface IThing {
    /// @param v value to search for
    /// @return x a number
    /// @return y another number
    fn value(u256 v) external view -> (uint128 x, uint128 y);
}

contract Thing is IThing {
    struct Value {
        uint128 x;
        uint128 y;
    }

    mapping(u256=>Value)  override value;
}
