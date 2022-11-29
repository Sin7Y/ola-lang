contract C {
    fn f(uint[] storage x) private {
    }
    fn g(uint[] memory x) public {
        f(x);
    }
}
// ----
// TypeError 9553: (113-114): Invalid type for argument in fn call. Invalid implicit conversion from uint256[] memory to uint256[] storage pointer requested.
