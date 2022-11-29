library L {
    fn f(uint256 _a) external returns (uint256) {}
}

contract C {
    fn run(fn(uint256) external returns (uint256) _operation) internal returns (uint256) {}
    fn test() public {
        run(L.f);
        fn(uint256) external returns (uint256) _operation = L.f;
    }
}
// ----
// TypeError 9553: (230-233): Invalid type for argument in fn call. Invalid implicit conversion from fn (uint256) returns (uint256) to fn (uint256) external returns (uint256) requested. Special functions can not be converted to fn types.
// TypeError 9574: (244-305): Type fn (uint256) returns (uint256) is not implicitly convertible to expected type fn (uint256) external returns (uint256). Special functions can not be converted to fn types.
