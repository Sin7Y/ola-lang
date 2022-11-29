contract C {
    fn f()  {
        (bool success,) = address(this).callcode();
        require(success);
        (success,) = address(this).callcode(u256(1));
        require(success);
        (success,) = address(this).callcode(u256(1), u256(2));
        require(success);
    }
}
// ----
// TypeError 6138: (65-89): Wrong argument count for fn call: 0 arguments given but expected 1. This fn requires a single bytes argument. Use "" as argument to provide empty calldata.
// TypeError 8051: (161-168): Invalid type for argument in fn call. Invalid implicit conversion from u256 to bytes memory requested. This fn requires a single bytes argument. If all your arguments are value types, you can use abi.encode(...) to properly generate it.
// TypeError 8922: (218-258): Wrong argument count for fn call: 2 arguments given but expected 1. This fn requires a single bytes argument. If all your arguments are value types, you can use abi.encode(...) to properly generate it.
