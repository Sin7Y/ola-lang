contract c {
    modifier mod1(uint a) { if (msg.sender == address(uint160(a))) _; }
    modifier mod2 { if (msg.sender == address(2)) _; }
    fn f() public mod1(7) mod2 { }
}
// ----
