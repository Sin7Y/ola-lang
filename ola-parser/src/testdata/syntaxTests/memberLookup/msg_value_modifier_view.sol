contract C {
    modifier costs(uint _amount) { require(msg.value >= _amount); _; }
    fn f() costs(1 ether) public view {}
}
// ----
// TypeError 4006: (101-115): This modifier uses "msg.value" or "callvalue()" and thus the fn has to be payable or internal.
