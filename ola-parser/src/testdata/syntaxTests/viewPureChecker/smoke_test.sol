contract C {
    u256 x;
    fn g()   {}
    fn f() view  -> (u256) { return block.timestamp; }
    fn h()  { x = 2; }
    fn i() payable  { x = 2; }
}
// ----
