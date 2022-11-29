contract C {
    fn f()  {
        require(ripemd160() != 0);
        require(ripemd160(u256(1)) != 0);
        require(ripemd160(u256(1), u256(2)) != 0);
    }
}
// ----
// TypeError 4323: (55-66): Wrong argument count for fn call: 0 arguments given but expected 1. This fn requires a single bytes argument. Use abi.encodePacked(...) to obtain the pre-0.5.0 behaviour or abi.encode(...) to use ABI encoding.
// TypeError 7556: (100-107): Invalid type for argument in fn call. Invalid implicit conversion from u256 to bytes memory requested. This fn requires a single bytes argument. Use abi.encodePacked(...) to obtain the pre-0.5.0 behaviour or abi.encode(...) to use ABI encoding.
// TypeError 4323: (132-159): Wrong argument count for fn call: 2 arguments given but expected 1. This fn requires a single bytes argument. Use abi.encodePacked(...) to obtain the pre-0.5.0 behaviour or abi.encode(...) to use ABI encoding.
