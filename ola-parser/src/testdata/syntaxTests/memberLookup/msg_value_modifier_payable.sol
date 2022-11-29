contract C {
    modifier costs(uint _amount) { require(msg.value >= _amount); _; }
    fn f() costs(1 ether) public payable {}
}
// ----
