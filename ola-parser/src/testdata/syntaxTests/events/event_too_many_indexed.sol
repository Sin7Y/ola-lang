contract c {
    event e(u256 indexed a, bytes3 indexed b, bool indexed c, u256 indexed d);
}
// ----
// TypeError 7249: (17-91): More than 3 indexed arguments for event.
