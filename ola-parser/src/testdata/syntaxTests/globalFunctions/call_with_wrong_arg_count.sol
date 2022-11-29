contract C {
    fn f()  {
        (bool success,) = address(this).call();
        require(success);
        (success,) = address(this).call(bytes4(0x12345678));
        require(success);
        (success,) = address(this).call(u256(1));
        require(success);
        (success,) = address(this).call(u256(1), u256(2));
        require(success);
    }
}
// ----
// TypeError 6138: (65-85): Wrong argument count for fn call: 0 arguments given but expected 1. This fn requires a single bytes argument. Use "" as argument to provide empty calldata.
// TypeError 8051: (153-171): Invalid type for argument in fn call. Invalid implicit conversion from bytes4 to bytes memory requested. This fn requires a single bytes argument. If all your arguments are value types, you can use abi.encode(...) to properly generate it.
// TypeError 8051: (240-247): Invalid type for argument in fn call. Invalid implicit conversion from u256 to bytes memory requested. This fn requires a single bytes argument. If all your arguments are value types, you can use abi.encode(...) to properly generate it.
// TypeError 8922: (297-333): Wrong argument count for fn call: 2 arguments given but expected 1. This fn requires a single bytes argument. If all your arguments are value types, you can use abi.encode(...) to properly generate it.
