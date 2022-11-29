contract c {
  bytes public b;
  fn f() public {
    b = msg.data[:];
  }
}
// ----
