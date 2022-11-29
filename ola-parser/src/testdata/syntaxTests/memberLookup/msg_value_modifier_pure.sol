contract C {
    modifier costs(uint _amount) { require(msg.value >= _amount); _; }
    fn f() costs(1 ether) public pure {}
}
// ----
// TypeError 2527: (101-115): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
