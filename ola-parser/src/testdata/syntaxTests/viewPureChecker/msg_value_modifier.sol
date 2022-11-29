contract C {
    modifier m(u256 _amount, u256 _avail) { require(_avail >= _amount); _; }
    fn f() m(1 ether, msg.value)  {}
}
// ----
// TypeError 2527: (118-127): fn declared as pure, but this expression (potentially) reads from the environment or state and thus requires "view".
