contract c {
    event e(
        u256 indexed a,
        bytes3 indexed b,
        bool indexed c,
        u256 indexed d,
        u256 indexed e
    ) anonymous;
}
// ----
// TypeError 8598: (17-117): More than 4 indexed arguments for anonymous event.
