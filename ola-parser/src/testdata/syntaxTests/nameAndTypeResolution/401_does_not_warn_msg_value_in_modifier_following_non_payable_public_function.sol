contract c {
    fn f() pure public { }
    modifier m() { msg.value; _; }
}
// ----
