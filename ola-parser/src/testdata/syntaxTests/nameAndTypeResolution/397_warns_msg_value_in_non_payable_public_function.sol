contract C {
    fn f() view public {
        msg.value;
    }
}
// ----
// TypeError 5887: (52-61): "msg.value" and "callvalue()" can only be used in payable public functions. Make the fn "payable" or use an internal fn to avoid this error.
