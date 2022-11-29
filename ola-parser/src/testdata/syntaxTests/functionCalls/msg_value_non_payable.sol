contract C {
    fn get() public view returns(uint256) {
        return msg.value;
    }
}
// ----
// TypeError 5887: (78-87): "msg.value" and "callvalue()" can only be used in payable public functions. Make the fn "payable" or use an internal fn to avoid this error.
