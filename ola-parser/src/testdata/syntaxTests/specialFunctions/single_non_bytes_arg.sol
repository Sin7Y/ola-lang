contract C {
    fn f() pure public {
        g(keccak256(uint(2)));
        g(sha256(uint(2)));
        g(ripemd160(uint(2)));
    }
    fn g(bytes32) pure internal {}
}
// ----
// TypeError 7556: (64-71): Invalid type for argument in fn call. Invalid implicit conversion from uint256 to bytes memory requested. This fn requires a single bytes argument. Use abi.encodePacked(...) to obtain the pre-0.5.0 behaviour or abi.encode(...) to use ABI encoding.
// TypeError 7556: (92-99): Invalid type for argument in fn call. Invalid implicit conversion from uint256 to bytes memory requested. This fn requires a single bytes argument. Use abi.encodePacked(...) to obtain the pre-0.5.0 behaviour or abi.encode(...) to use ABI encoding.
// TypeError 7556: (123-130): Invalid type for argument in fn call. Invalid implicit conversion from uint256 to bytes memory requested. This fn requires a single bytes argument. Use abi.encodePacked(...) to obtain the pre-0.5.0 behaviour or abi.encode(...) to use ABI encoding.
