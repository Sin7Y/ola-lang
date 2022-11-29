contract C {
    modifier m(u256 _amount, u256 _avail) { require(_avail >= _amount); _; }
    fn f() m(1 ether, msg.value)  {}
}
// ----
// TypeError 5887: (118-127): "msg.value" and "callvalue()" can only be used in payable  functions. Make the fn "payable" or use an internal fn to avoid this error.
